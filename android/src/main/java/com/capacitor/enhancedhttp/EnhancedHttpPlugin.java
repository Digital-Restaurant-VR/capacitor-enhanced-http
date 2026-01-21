package com.capacitor.enhancedhttp;

import android.util.Log;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.PluginMethod;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.MediaType;
import okhttp3.RequestBody;

import java.util.Iterator;
import javax.net.ssl.*;
import java.io.IOException;
import java.security.cert.X509Certificate;

@CapacitorPlugin(name = "CapacitorEnhancedHttp")
public class EnhancedHttpPlugin extends Plugin {

    @PluginMethod
    public void unsafeGet(PluginCall call) {
        String url = call.getString("url");
        JSObject headers = call.getObject("headers");

        OkHttpClient client = getUnsafeClient();

        Request.Builder builder = new Request.Builder().url(url).get();

        // apply headers
        if (headers != null) {
            Iterator<String> it = headers.keys();
            while (it.hasNext()) {
                String key = it.next();
                String value = headers.optString(key, null);
                if (value != null) {
                    builder.addHeader(key, value);
                }
            }
        }

        Request request = builder.build();

        client.newCall(request).enqueue(new Callback() {
            @Override public void onFailure(Call callObj, IOException e) {
                call.reject(e.getMessage());
            }

            @Override public void onResponse(Call callObj, Response response) throws IOException {
                JSObject ret = new JSObject();
                ret.put("status", response.code());
                ret.put("data", response.body() != null ? response.body().string() : "");
                call.resolve(ret);
            }
        });
    }

    @PluginMethod
    public void unsafePost(PluginCall call) {
        String url = call.getString("url");
        if (url == null || url.isEmpty()) {
            call.reject("Missing url");
            return;
        }

        JSObject headers = call.getObject("headers");

        // JS may send `data` either as an object (recommended) or as a JSON string.
        JSObject dataObj = call.getObject("data");
        String dataStr = call.getString("data");

        String bodyString = "";
        if (dataObj != null) {
            // JSObject#toString() returns JSON
            bodyString = dataObj.toString();
        } else if (dataStr != null) {
            bodyString = dataStr;
        }

        MediaType JSON = MediaType.parse("application/json; charset=utf-8");
        if (JSON == null) {
            JSON = MediaType.parse("application/json");
        }
        RequestBody body = RequestBody.create(bodyString, JSON);

        OkHttpClient client = getUnsafeClient();

        Request.Builder builder = new Request.Builder()
                .url(url)
                .post(body);

        // apply headers
        if (headers != null) {
            Iterator<String> it = headers.keys();
            while (it.hasNext()) {
                String key = it.next();
                String value = headers.optString(key, null);
                if (value != null) {
                    builder.addHeader(key, value);
                }
            }
        }

        // Ensure Content-Type is set for JSON bodies unless caller explicitly overrides it.
        if (headers == null || headers.optString("Content-Type", null) == null) {
            builder.addHeader("Content-Type", "application/json");
        }


        Request request = builder.build();

        client.newCall(request).enqueue(new Callback() {
            @Override public void onFailure(Call callObj, IOException e) {
                call.reject(e.getMessage());
            }

            @Override public void onResponse(Call callObj, Response response) throws IOException {
                JSObject ret = new JSObject();
                ret.put("status", response.code());
                ret.put("data", response.body() != null ? response.body().string() : "");
                call.resolve(ret);
            }
        });
    }

    private OkHttpClient getUnsafeClient() {
        try {
            TrustManager[] trustAllCerts = new TrustManager[]{
                new X509TrustManager() {
                    public void checkClientTrusted(X509Certificate[] chain, String authType) {}
                    public void checkServerTrusted(X509Certificate[] chain, String authType) {}
                    public X509Certificate[] getAcceptedIssuers() { return new X509Certificate[]{}; }
                }
            };

            SSLContext sslContext = SSLContext.getInstance("SSL");
            sslContext.init(null, trustAllCerts, new java.security.SecureRandom());

            return new OkHttpClient.Builder()
                    .sslSocketFactory(sslContext.getSocketFactory(), (X509TrustManager) trustAllCerts[0])
                    .hostnameVerifier((hostname, session) -> true)
                    .build();

        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}