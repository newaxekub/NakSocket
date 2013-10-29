package nakSocket
{
	import flash.events.Event;
	
	public class SocketEvent extends Event
	{
		public static const CONNECT_EVENT:String = "onConnect";
		public static const CONNECT_LOSE:String = "onConnectLose";
		public static const GET_SERVER:String = "onGetServer";
		public static const LOGIN_EVENT:String = "onLogin";
		public static const USER_LEAVE:String = "onUserLeave";
		public static const PUBLIC_MESSAGE:String = "onPublicMessage";
		
		public var params:Object = new Object();
		
		public function SocketEvent(type:String, params:Object)
		{
			super(type);
			this.params = params;
		}
	}
}