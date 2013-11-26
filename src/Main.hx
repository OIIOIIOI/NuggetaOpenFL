package;

import com.nuggeta.network.Message;
import com.nuggeta.ngdl.nobjects.StartResponse;
import com.nuggeta.ngdl.nobjects.StartStatus;
import com.nuggeta.NuggetaPlug;
import com.nuggeta.util.NList;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxe.Timer;
import openfl.Assets;

class Main extends Sprite {
	
	//UI
	var nuggetaImg:Bitmap;
	var nuggetaText:TextField;
	// Plug
	var nuggetaPlug:NuggetaPlug;
	
	var inited:Bool;
	
	public static function main () {
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
	
	public function new () {
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedHandler);
	}
	
	function addedHandler (e:Event) {
		removeEventListener(Event.ADDED_TO_STAGE, addedHandler);
		stage.addEventListener(Event.RESIZE, resizeHandler);
		#if ios
		Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	function resizeHandler (e:Event) {
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init () {
		if (inited) return;
		inited = true;
		
		nuggetaImg = new Bitmap (Assets.getBitmapData("img/nuggeta_off.png"));
		Lib.current.addChild(nuggetaImg);
		nuggetaImg.x = (stage.stageWidth - nuggetaImg.width) / 2;
		nuggetaImg.y = (stage.stageHeight - nuggetaImg.height) / 2;
		
		var format:TextFormat = new TextFormat("Arial", 20);
		format.align = TextFormatAlign.CENTER;
		nuggetaText = new TextField();
		nuggetaText.defaultTextFormat = format;
		nuggetaText.text = "Connecting to Nuggeta...";
		nuggetaText.width = 300;
		nuggetaText.height = 50;
		nuggetaText.x = (stage.stageWidth - nuggetaText.width) / 2;
		nuggetaText.y = nuggetaImg.y + nuggetaImg.height;
		Lib.current.addChild(nuggetaText);
		
		// Replace with your Game ID
		nuggetaPlug = new NuggetaPlug("nuggeta://YOUR_GAME_ID");
		// Pump version
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		// Handler version
		//nuggetaPlug.addStartResponseHandler(startResponseHandler);
		nuggetaPlug.start();
	}
	
	function enterFrameHandler (e:Event) {
		var messages:NList<Message> = nuggetaPlug.pump();
		for (i in 0...messages.size()) {
			var m:Message = messages.get(i);
			if (Std.is(m, StartResponse)) {
				startResponseHandler(cast m);
			} else {
				nuggetaText.text = "Unhandled message: " + m;
			}
		}
	}
	
	function startResponseHandler (sr:StartResponse) {
		if (sr.getStartStatus() == StartStatus.FAILED) {
			nuggetaText.text = "Connection Failed to Nuggeta";
		}
		else if (sr.getStartStatus() == StartStatus.READY) {
			nuggetaImg.bitmapData = Assets.getBitmapData("img/nuggeta_on.png");
			nuggetaText.text = "Connection Ready with Nuggeta";
		}
		else if (sr.getStartStatus() == StartStatus.REFUSED) {
			nuggetaText.text = "Connection Refused to Nuggeta";
		}
		else if (sr.getStartStatus() == StartStatus.WARNED) {
			nuggetaImg.bitmapData = Assets.getBitmapData("img/nuggeta_on.png");
			nuggetaText.text = "Connection Warned with Nuggeta";
		}
	}
	
}










