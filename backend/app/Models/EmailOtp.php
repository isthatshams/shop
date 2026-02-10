<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EmailOtp extends Model
{
    use HasFactory;

    protected $fillable = [
        'email',
        'otp',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'expires_at' => 'datetime',
        ];
    }

    public function isExpired(): bool
    {
        return $this->expires_at->isPast();
    }

    public static function generateFor(string $email): self
    {
        // Delete any existing OTPs for this email
        self::where('email', $email)->delete();

        // Generate new 6-digit OTP
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        return self::create([
            'email' => $email,
            'otp' => $otp,
            'expires_at' => now()->addMinutes(10),
        ]);
    }

    public static function verify(string $email, string $otp): bool
    {
        $record = self::where('email', $email)
            ->where('otp', $otp)
            ->first();

        if (!$record || $record->isExpired()) {
            return false;
        }

        // Delete the OTP after successful verification
        $record->delete();

        return true;
    }
}
