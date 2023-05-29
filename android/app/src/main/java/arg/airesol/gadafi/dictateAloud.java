package org.airesol.gadafi;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class dictateAloud extends FlutterActivity {
    private String sharedPdfPath;
    private static final String CHANNEL = "app.channel.shared.data";

    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        String action = intent.getAction();
        String type = intent.getType();

        if(Intent.ACTION_SEND.equals(action) && type != null){
            if("text/plain".equals(type)){
                handleSendText(intent);
            }
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (methodCall, result) -> {
                            if(methodCall.method.contentEquals("getSharedText")){
                                result.success(sharedPdfPath);
                                sharedPdfPath = null;
                            }
                        }
                );
    }
    void handleSendText(Intent intent){
        sharedPdfPath = intent.getStringExtra(Intent.EXTRA_TEXT);
    }
}


