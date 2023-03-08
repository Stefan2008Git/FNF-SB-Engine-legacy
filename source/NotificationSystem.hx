package;

import com.hxpext.notification.Notification;

using StringTools;

class NotificationSystem
{
    override public function create():Void
    {
        super.create();

        var notification = new Notification();
        notification.title = "SBEngine.exe";
        notification.message = "Welcome to SB Engine";
        notification.duration = 5000; // 5 seconds
        notification.show();
    }
}