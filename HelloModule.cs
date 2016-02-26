using Nancy;

namespace HelloAws
{
	public class HelloModule : NancyModule
	{
		public HelloModule()
		{
			Get["/"] = _ => "Hello AWS!";
		}
	}
}