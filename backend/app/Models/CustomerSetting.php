<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CustomerSetting extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'language',
        'theme',
        'notifications_enabled',
        'addresses',
        'payment_methods',
    ];

    protected function casts(): array
    {
        return [
            'notifications_enabled' => 'boolean',
            'addresses' => 'array',
            'payment_methods' => 'array',
        ];
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }
}
