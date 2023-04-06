import android.content.Context;
import android.content.Intent;
import android.graphics.pdf.PdfDocument;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.NonNull;

import java.io.File;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
//    private PdfDocument sharedPdf;
//    private static final String CHANNEL = "app.channel.shared.data";
//    private File chosenPdf;

//    @Override
//    protected void onCreate(Bundle savedInstanceState){
//        super.onCreate(savedInstanceState);
//        Intent intent = getIntent();
//        String action = intent.getAction();
//        String type = intent.getType();
//
//        if(Intent.ACTION_OPEN_DOCUMENT.equals(action) && type != null){
//            if ("application/pdf".equals(type)) {
//       //         handleSendFile(intent); //handle file being sent
//                onReceive(getApplicationContext(), intent); //handle file being sent
//            }
//        }
//    }
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        GeneratedPluginRegistrant.registerWith(flutterEngine);

//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//                .setMethodCallHandler(
//                        (call, result) -> {
//                            if(call.method.contentEquals("getSharedPdf")){
//                                result.success(sharedPdf);
//                                sharedPdf = null;
//                            }
//                        }
//                );
    }
//    void handleSendFile(Intent intent){
////        sharedPdf = new Intent(Intent.ACTION_VIEW, PdfDocument.Page.parse(sharedPdf));
////        sharedPdf = intent.getParcelableExtra(Intent.EXTRA_PACKAGE_NAME); //change the extra package intent
//
//    }
//    public void onReceive(Context context, Intent intent){
//        //Intent service = new Intent(context, startDictating.class);
//        //service.setDataAndType(Uri.fromFile(chosenPdf), "application/pdf");
//        //service.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
////        service.setData(Uri.fromFile(chosenPdf));
//        //context.startService(service);
//        //context.startActivity(service);
//    }
}

