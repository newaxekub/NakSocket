package nakSocket
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.Timer;

	public class NakSocket extends EventDispatcher
	{
		private var socket:Socket;

		public var serverName:String = "";
		public var userName:String = "";

		public function NakSocket(IP:String, Port:Number)
		{
			socket = new Socket(IP,Port);
			socket.addEventListener(IOErrorEvent.IO_ERROR, onConectError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onGetDat);
			socket.addEventListener(Event.CLOSE, onClosed);
		}

		private function onConectError(e:IOErrorEvent):void
		{
			var params:Object = new Object();
			params.success = false;
			params.errorMessage = "Can not connect to server.";
			dispatchEvent(new SocketEvent(SocketEvent.CONNECT_EVENT, params));
		}

		private function onClosed(e:Event):void
		{
			socket.close();
			var timer:Timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, timeClose);
			function timeClose(e:TimerEvent)
			{
				dispatchEvent(new SocketEvent(SocketEvent.CONNECT_LOSE, {}));
				timer.stop();
			}
			timer.start();
		}

		private function onGetDat(e:ProgressEvent):void
		{
			var params:Object = new Object();
			var str:String = e.target.readUTFBytes(e.target.bytesAvailable);
			var mainArray:Array = str.split("|,,|");

			for (var m:int = 0; m < mainArray.length; m++)
			{
				var dataArray:Array = mainArray[m].split("|R|");
				var dataType:String = "|,,|" + dataArray[0];

				if (mainArray[m] == "ConnectComplete")
				{
					dispatchEvent(new SocketEvent(SocketEvent.CONNECT_EVENT, {"success": true}));
				}

				if (dataType == DataType.GET_SERVER)
				{
					params = new Object();
					var serverArray:Array = dataArray[1].split("/");
					var server:Vector.<Server> = new Vector.<Server>();
					for (var s:Number = 0; s < serverArray.length; s++)
					{
						serverArray[s] = serverArray[s].split(",");
						var ser:Server = new Server(serverArray[s][0], int(serverArray[s][1]), int(serverArray[s][2]), serverArray[s][3]);
						server.push(ser);
					}
					params.server = server;
					dispatchEvent(new SocketEvent(SocketEvent.GET_SERVER, params));
				}

				if (dataType == DataType.LOGIN_SERVER)
				{
					var param:Object = {};
					if (dataArray[1] == DataType.SERVER_LOGIN_COMPLETE)
					{
						dispatchEvent(new SocketEvent(SocketEvent.LOGIN_EVENT, {"success": true}));
					}
					else if (dataArray[1] == DataType.SERVER_FULL)
					{
						param.success = false;
						param.errorMessage = "Server is basy.";
						dispatchEvent(new SocketEvent(SocketEvent.LOGIN_EVENT, param));
					}
					else if (dataArray[1] == DataType.SERVER_NULL)
					{
						param.success = false;
						param.errorMessage = "Server not found.";
						dispatchEvent(new SocketEvent(SocketEvent.LOGIN_EVENT, param));
					}
					else if (dataArray[1] == DataType.SERVER_OFFLINE)
					{
						param.success = false;
						param.errorMessage = "Server is offline mode.";
						dispatchEvent(new SocketEvent(SocketEvent.LOGIN_EVENT, param));
					}
					else if (dataArray[1] == DataType.SERVER_NAME_USED)
					{
						param.success = false;
						param.errorMessage = "User name is used.";
						dispatchEvent(new SocketEvent(SocketEvent.LOGIN_EVENT, param));
					}
				}
				if (dataType == DataType.LEAVE)
				{
					dispatchEvent(new SocketEvent(SocketEvent.USER_LEAVE, {"userName": dataArray[1]}));
				}
				if (dataType == DataType.PUBLIC_MESSAGE)
				{
					params = new Object();
					params.userName = dataArray[1];
					params.message = dataArray[2];
					dispatchEvent(new SocketEvent(SocketEvent.PUBLIC_MESSAGE, params));
				}
			}
		}

		public function getServer():void
		{
			socket.writeUTFBytes(DataType.GET_SERVER);
			socket.flush();
		}

		public function login(userName:String, serverName:String):void
		{
			this.serverName = serverName;
			this.userName = userName;

			socket.writeUTFBytes(DataType.LOGIN_SERVER + "|R|" + serverName + "|R|" + userName);
			socket.flush();
		}

		public function send(message:String):void
		{
			socket.writeUTFBytes(DataType.PUBLIC_MESSAGE + "|R|" + serverName + "|R|" + userName + "|R|" + message);
			socket.flush();
		}
	}
}