package packpan.nodes 
{
	import cobaltric.ContainerGame;
	import flash.display.Bitmap;
	import flash.display.ColorCorrection;
	import flash.geom.ColorTransform;
	import packpan.iface.IColorable;
	import packpan.mails.ABST_Mail;
	import packpan.PhysicalEntity;
	import packpan.PP;
	import packpan.PhysicsUtils;
	import flash.geom.Point;
	
	/**
	 * A goal bin.
	 * @author Alexander Huynh
	 */
	public class NodeBin extends ABST_Node implements IColorable
	{
		/// The color of this object, PP.COLOR_NONE if uncolored.
		private var color:uint = PP.COLOR_NONE;
		
		//the strength of the forces that center the package
		private var friction:Number = 5;
		private var spring:Number = 10;
		
		public var occupied:Boolean;			// if true, there is a package in this bin
		
		[Embed(source="../../../img/binNormal.png")]	// embed code; change this path to change the image
		private var CustomBitmap:Class;					// must be directly below the embed code
		
		public function NodeBin(_cg:ContainerGame, _json:Object) 
		{
			super(_cg, _json, new CustomBitmap());
			
			occupied = false;
			
			// the color of this mail if it is colored
			color = PP.COLOR_NONE;	
			if (json["color"])
				setColor(json["color"]);
		}
		
		/**
		 * Called by a Mail object to manipulate the Mail object
		 * Draws Mail objects to its center
		 * 
		 * @param	mail	the Mail to be affected
		 */
		override public function affectMail(mail:ABST_Mail):void
		{
			if (occupied)
			{
				return;		// TODO failure state
			}
			
			mail.state.addForce(PhysicsUtils.linearDamping(friction, mail.state, new Point(0, 0)));
			mail.state.addForce(PhysicsUtils.linearRestoreX(spring, mail.state, position.x));
			mail.state.addForce(PhysicsUtils.linearRestoreY(spring, mail.state, position.y));
				
			// once snapping animation is complete
			if (Point.distance(position,mail.state.position) < 0.2)
			{
				mail.state = new PhysicalEntity(1, new Point(position.x, position.y));
				mail.mc_object.scaleX = mail.mc_object.scaleY = .8;
				occupied = true;
				
				// fail if mail and bin are colored and colors don't match.
				if (mail is IColorable && !isSameColor(IColorable(mail).getColor()))
				{
					mail.mailState = PP.MAIL_FAILURE;
					return;
				}
				// success state
				mail.mailState = PP.MAIL_SUCCESS;
			}
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////
		// IColorable
		///////////////////////////////////////////////////////////////////////////////////////////
		
		public function isColored():Boolean
		{
			return getColor() != PP.COLOR_NONE;
		}
		
		public function isSameColor(col:uint):Boolean
		{
			return !isColored() || getColor() == col;
		}
		
		public function setColor(colS:String):void
		{
			var col:uint = convertColor(colS);
			
			var ct:ColorTransform = new ColorTransform();
			ct.redMultiplier = int(col / 0x10000) / 255;
			ct.greenMultiplier = int(col % 0x10000 / 0x100) / 255;
			ct.blueMultiplier = col % 0x100 / 255;
			mc_object.transform.colorTransform = ct;
			
			color = col;
		}
		
		public function getColor():uint
		{
			return color;
		}
	}
}