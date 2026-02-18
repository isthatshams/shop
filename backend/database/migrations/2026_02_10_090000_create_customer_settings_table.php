<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('customer_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained()->cascadeOnDelete()->unique();
            $table->string('language', 5)->default('en');
            $table->string('theme', 10)->default('system');
            $table->boolean('notifications_enabled')->default(true);
            $table->json('addresses')->nullable();
            $table->json('payment_methods')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_settings');
    }
};
