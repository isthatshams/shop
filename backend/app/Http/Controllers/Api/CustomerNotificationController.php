<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CustomerNotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $customer = $request->user();

        $notifications = $customer->notifications()
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => [
                'notifications' => $notifications,
                'unread_count' => $customer->unreadNotifications()->count(),
            ],
        ]);
    }

    public function markRead(Request $request, string $id): JsonResponse
    {
        $customer = $request->user();
        $notification = $customer->notifications()->where('id', $id)->first();

        if (!$notification) {
            return response()->json([
                'success' => false,
                'message' => 'Notification not found',
            ], 404);
        }

        $notification->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read',
        ]);
    }

    public function registerDevice(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string|max:500',
            'platform' => 'nullable|string|in:ios,android,web',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $customer = $request->user();
        $data = $validator->validated();

        $device = DeviceToken::firstOrNew(['token' => $data['token']]);
        $device->platform = $data['platform'] ?? $device->platform;
        $device->last_used_at = now();
        $device->notifiable()->associate($customer);
        $device->save();

        return response()->json([
            'success' => true,
            'message' => 'Device token registered',
        ]);
    }
}
