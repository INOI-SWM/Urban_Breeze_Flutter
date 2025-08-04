package com.inoi.ridingmate.dev;

import androidx.health.connect.client.HealthConnectClient;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainActivity extends FlutterFragmentActivity {
    private static final String CHANNEL = "health_connect";
    private HealthConnectClient healthConnectClient;
    private ExecutorService executor;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        initializeHealthConnect();
        // MethodChannel 설정
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                switch (call.method) {
                    case "isAvailable":
                        result.success(isHealthConnectAvailable());
                        break;
                    case "requestPermissions":
                        // TODO: 권한 요청 로직 구현 예정
                        result.success(true);
                        break;
                    case "getExerciseSessions":
                        // TODO: 운동 세션 조회 로직 구현 예정
                        result.success("[]");
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            });
    }

    private void initializeHealthConnect() {
        try {
            healthConnectClient = HealthConnectClient.getOrCreate(this);
            executor = Executors.newSingleThreadExecutor();
        } catch (Exception e) {
            // Health Connect 초기화 실패 처리
            e.printStackTrace();
        }
    }

    private boolean isHealthConnectAvailable() {
        try {
            int sdkStatus = HealthConnectClient.getSdkStatus(this);
            return sdkStatus == HealthConnectClient.SDK_AVAILABLE;
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (executor != null && !executor.isShutdown()) {
            executor.shutdown();
        }
    }
} 