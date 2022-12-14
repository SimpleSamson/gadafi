package arg.airesol.gadafi
import java.io.File
import android.os.Bundle
import android.graphics.pdf.PdfDocument
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall

class startDictating(chosenFile: File?, savedInstanceState: Bundle?) : FlutterActivity() {
    private val pdfDoc: PdfDocument? = null
    var gadafiChannel: MethodChannel? = null

    init {
        super.onCreate(savedInstanceState)
        val intent = intent
        val action = intent.action
        val type = intent.type
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //  Intent intent
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            gCHANNEL
        ) // .setMethodCallHandler(flutterEngine.getDartExecutor().getBinaryMessenger(), gCHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                if (call.method.contentEquals("getSharedPdf")) {
                    result.success(pdfDoc)
                    //                                pdfDoc = null;
                }
            }
    }

    //@Override
    protected fun onHandleIntent(intent: Intent?) {
        //speakpdf
        gadafiChannel = MethodChannel((flutterEngine as BinaryMessenger?)!!, "gadafiSpeakerChannel")
        var pdfFilePath: String
        gadafiChannel!!.invokeMethod("speakPdf", pdfDoc, object : MethodChannel.Result {
            override fun success(o: Any?) {
                Log.d("successfully", o.toString())
            }
            override fun error(s: String, s1: String?, o: Any?) {}
            override fun notImplemented() {}
        })
    }

    companion object {
        const val gCHANNEL = "app.channel.shared.data"
    }
}