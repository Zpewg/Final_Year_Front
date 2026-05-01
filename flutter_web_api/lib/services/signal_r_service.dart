import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  late HubConnection hubConnection;
  final String serverUrl = "http://localhost:7152/notificationHub"; // 10.0.2.2 e localhost pentru emulatorul Android

  // Functia de initializare
  void initSignalR(int userId, Function(String) onNotificationReceived) {
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();

    // 1. Ascultăm evenimentul definit în C# (ReceiveNotification)
    hubConnection.on("ReceiveNotification", (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        onNotificationReceived(arguments[0] as String);
      }
    });

    // 2. Pornim conexiunea
    hubConnection.start()?.then((_) {
      print("SignalR Connected!");
      // 3. Odată conectați, intrăm în grupul specific userului nostru (metoda din C#)
      hubConnection.invoke("JoinUserGroup", args: [userId]);
    }).catchError((err) => print("SignalR Error: $err"));
  }

  void stopConnection() {
    hubConnection.stop();
  }
}