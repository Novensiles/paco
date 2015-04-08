package com.pacoapp.paco.net;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.net.URL;
import java.util.List;

import javax.net.ssl.HttpsURLConnection;

import org.json.JSONException;

import android.util.Log;
import android.util.Pair;

import com.google.android.apps.paco.PacoConstants;
import com.google.android.apps.paco.utils.AndroidUtils;
import com.google.android.gms.auth.GoogleAuthUtil;
import com.google.common.collect.Lists;

public class PacoBackgroundService extends GetInBackground {

  public static final String POST = "POST";
  public  static final String GET = "GET";
  private static final int MAX_ATTEMPTS = 2;

  private String url;
  private String httpMethod;
  private String body;
  private int attempts;

  public PacoBackgroundService(NetworkClient client, String url, String body) {
    super(client);
    this.url = url;
    this.httpMethod = POST;
    this.body = body;
  }

  public PacoBackgroundService(NetworkClient client, String url) {
    super(client);
    this.url = url;
    this.httpMethod = GET;
  }

  @Override
  protected void doRequest() throws IOException, JSONException {
    String token = fetchToken();
    if (token == null) {
      // error has already been handled in fetchToken()
      return;
    }
    userPrefs.setAccessToken(token);
    List<Pair<String,String>> headers = null; // TODO do we want to pass headers in?
    if (headers == null) {
      headers = Lists.newArrayList();
    }
    addStandardHeaders(headers);
    addAccessTokenBearerHeader(fetchToken(), headers);

    URL u = new URL(url);
    HttpsURLConnection urlConnection = (HttpsURLConnection) u.openConnection();
    for (Pair<String, String> header : headers) {
      urlConnection.addRequestProperty(header.first, header.second);
    }

    if (POST.equals(httpMethod)) {
      urlConnection.setDoOutput(true);
      urlConnection.setRequestMethod(POST);
      OutputStreamWriter writer = new OutputStreamWriter(urlConnection.getOutputStream(), AbstractAuthTokenTask.UTF_8);
      writer.write(body);
      writer.flush();
    }



    int sc = urlConnection.getResponseCode();
    if (sc == 200) {
      InputStream is = urlConnection.getInputStream();
      String result = readResponse(urlConnection.getInputStream());
      Log.d(PacoConstants.TAG, "RESULT = " + result);
      is.close();
      networkClient.showAndFinish(result);
      return;
    } else if (sc == 401) {
        GoogleAuthUtil.invalidateToken(networkClient.getContext(), token);
        onError("Server auth error, please try again.", null);
        Log.i(PacoConstants.TAG, "Server auth error: " + readResponse(urlConnection.getErrorStream()));
        if (attempts < MAX_ATTEMPTS) {
          attempts++;
          Log.i(PacoConstants.TAG, "Attempt: " + attempts + " for url:  " + url);
          doRequest();
        }
        return;
    } else {
      onError("Server returned the following error code: " + sc, null);
      return;
    }

  }

  public void addStandardHeaders(List<Pair<String, String>> headers) {
    headers.add(new Pair<String, String>("http.useragent", "Android"));
    headers.add(new Pair<String, String>("paco.version", AndroidUtils.getAppVersion(networkClient.getContext())));
    headers.add(new Pair<String, String>("pacoProtocol", "4"));
  }

  public void addAccessTokenBearerHeader(String accessToken, final List<Pair<String, String>> headers) {
    headers.add(new Pair<String, String>("Authorization", "Bearer " + accessToken));
  }



}