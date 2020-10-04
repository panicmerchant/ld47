package en;

class Item extends Entity {
	public static var ALL : Array<Item> = [];
	public var type : Enum_ItemType;
	public var origin : CPoint;
	public var inVault = false;
	public var shineColor = new h3d.Vector();

	public function new(x,y, t:Enum_ItemType) {
		super(x, y);
		ALL.push(this);
		gravityMul*=0.5;
		frictX = frictY = 0.96;

		type = t;
		origin = makePoint();
		cd.setS("pickLock",0.25);

		game.scroller.add(spr, Const.DP_BG);
		spr.set(switch type {
			case Ammo: "itemAmmo";
			case DoorKey: "itemKey";
			case Diamond: "itemDiamond";
		});

		switch type {
			case Diamond: darkMode = GoOutOfGame;
			case _:
		}
	}

	override function onDark() {
		super.onDark();

		if( isGrabbedByHero() )
			hero.dropItem();

		if( darkMode==GoOutOfGame )
			setPosCase(origin.cx, origin.cy);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function onLand(fallCHei:Float) {
		super.onLand(fallCHei);

		if( fallCHei>=0.5 ) {
			dx*=0.5;
			dy = -0.1;
		}
	}

	public inline function isGrabbedByHero() return hero!=null && hero.isGrabbing(this);

	override function postUpdate() {
		super.postUpdate();
		if( hero.isGrabbing(this) ) {
			spr.y-=Const.GRID*1.1;
		}

		if( !isOutOfTheGame() && !isGrabbedByHero() && type==Diamond && !cd.hasSetS("fx",rnd(0.1,0.4)) )
			fx.shine(centerX+rnd(0,5,true), centerY+rnd(0,4,true), 0x4a98ff);

		// Shine
		if( !cd.has("keepShine") ) {
			shineColor.r*=Math.pow(0.95, tmod);
			shineColor.g*=Math.pow(0.85, tmod);
			shineColor.b*=Math.pow(0.70, tmod);
		}
		spr.colorAdd.load(baseColor);
		spr.colorAdd.r += shineColor.r;
		spr.colorAdd.g += shineColor.g;
		spr.colorAdd.b += shineColor.b;

		if( !inVault && !isGrabbedByHero() && !cd.hasSetS("itemBlink",1) ) {
			cd.setS("keepShine",0.1);
			shineColor.setColor(0x4a98ff);
		}
	}

	override function update() {
		super.update();

		if( inVault )
			darkMode = Stay;

		if( !inVault && distCase(hero)<=0.9 && !isOutOfTheGame() && !hero.isGrabbingAnything() && !cd.has("pickLock") ) {
			switch type {
			case Ammo:
				hero.addAmmo(6);
				destroy();

			case Diamond:
				hero.grabItem(this);

			case DoorKey:
				hero.grabItem(this);
			}
		}
	}
}