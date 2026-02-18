<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class PushNotificationService
{
    public function send(array $tokens, string $title, string $body, array $data = []): void
    {
        $serverKey = config('services.fcm.server_key');

        if (empty($serverKey) || empty($tokens)) {
            return;
        }

        $chunks = array_chunk($tokens, 900);

        foreach ($chunks as $batch) {
            $payload = [
                'registration_ids' => array_values($batch),
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                ],
                'data' => $data,
            ];

            $response = Http::withHeaders([
                'Authorization' => 'key=' . $serverKey,
                'Content-Type' => 'application/json',
            ])->post('https://fcm.googleapis.com/fcm/send', $payload);

            if (!$response->successful()) {
                Log::warning('FCM push notification failed', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
            }
        }
    }
}
