package nakSocket
{
	
	public class Server
	{
		public static const ONLINE:String = "Online";
		public static const OFFLINE:String = "Offline";
		
		public var name:String;
		public var maxUser:int = 100;
		public var numUser:int = 0;
		public var status:String = ONLINE;
		
		public function Server(name:String, numUser:int = 0, maxUser:int = 100, status:String = ONLINE)
		{
			this.name = name;
			this.numUser = numUser;
			this.maxUser = maxUser;
			this.status = status;
		}
	}
}