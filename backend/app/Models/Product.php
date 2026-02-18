<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Notification;
use App\Models\User;
use App\Models\DeviceToken;
use App\Notifications\OutOfStockNotification;
use App\Services\PushNotificationService;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'price',
        'original_price',
        'stock',
        'is_active',
        'is_featured',
        'images',
        'category_id',
        'rating',
        'reviews_count',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'original_price' => 'decimal:2',
            'rating' => 'decimal:1',
            'is_active' => 'boolean',
            'is_featured' => 'boolean',
            'images' => 'array',
        ];
    }

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($product) {
            if (empty($product->slug)) {
                $product->slug = Str::slug($product->name);
            }
        });

        static::updated(function ($product) {
            if (
                $product->wasChanged('stock') &&
                $product->stock <= 0 &&
                $product->getOriginal('stock') > 0
            ) {
                $admins = User::query()->get();
                if ($admins->isNotEmpty()) {
                    Notification::send($admins, new OutOfStockNotification($product));

                    $tokens = DeviceToken::query()
                        ->where('notifiable_type', User::class)
                        ->whereIn('notifiable_id', $admins->pluck('id'))
                        ->pluck('token')
                        ->unique()
                        ->values()
                        ->all();

                    if (!empty($tokens)) {
                        app(PushNotificationService::class)->send(
                            $tokens,
                            'Product out of stock',
                            "{$product->name} is out of stock.",
                            ['type' => 'stock_alert', 'product_id' => $product->id]
                        );
                    }
                }
            }
        });
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function isInStock(): bool
    {
        return $this->stock > 0;
    }

    public function hasDiscount(): bool
    {
        return $this->original_price !== null && $this->original_price > $this->price;
    }

    public function getDiscountPercentage(): int
    {
        if (!$this->hasDiscount()) {
            return 0;
        }
        return (int) round((($this->original_price - $this->price) / $this->original_price) * 100);
    }

    public function getFirstImageAttribute(): ?string
    {
        return $this->images[0] ?? null;
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('is_featured', true);
    }

    public function scopeInStock($query)
    {
        return $query->where('stock', '>', 0);
    }
}
