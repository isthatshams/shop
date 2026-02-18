<?php

namespace App\Notifications;

use App\Models\Product;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class OutOfStockNotification extends Notification
{
    use Queueable;

    public function __construct(public Product $product) {}

    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function toDatabase(object $notifiable): array
    {
        return [
            'title' => 'Product out of stock',
            'body' => "{$this->product->name} is out of stock.",
            'type' => 'stock_alert',
            'meta' => [
                'product_id' => $this->product->id,
                'product_name' => $this->product->name,
            ],
        ];
    }
}
