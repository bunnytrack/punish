class SoloRocket extends RocketMk2;

var string Sinner;

auto state Flying {
	simulated function ProcessTouch(Actor Other, Vector HitLocation) {
		Explode(HitLocation, Normal(HitLocation - Other.Location));
	}

	simulated function Explode(vector HitLocation, vector HitNormal) {
		local UT_SpriteBallExplosion s;

		s = Spawn(class'UT_SpriteBallExplosion',,, HitLocation + HitNormal * 16);
		s.RemoteRole = ROLE_None;

		BlowUpSinner(HitLocation);

		Destroy();
	}

	function BlowUpSinner(vector HitLocation) {
		local actor  Victims;
		local float  damageScale, dist;
		local vector dir;

		foreach VisibleCollidingActors(class'Actor', Victims, 220, HitLocation) {
			if (
				PlayerPawn(Victims) != none &&
				PlayerPawn(Victims).PlayerReplicationInfo.PlayerName == Sinner
			) {
				dir         = Victims.Location - HitLocation;
				dist        = FMax(1, VSize(dir));
				dir         = dir / dist;
				damageScale = 1 - FMax(0, (dist - Victims.CollisionRadius) / 220);

				Victims.TakeDamage(
					damageScale * Damage,
					Instigator,
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					damageScale * MomentumTransfer * dir,
					MyDamageType
				);

				break;
			}
		}

		MakeNoise(1);
	}
}

DefaultProperties {
	ExplosionDecal=none
}