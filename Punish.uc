class Punish expands Mutator;

var bool       bInitialised;
var PlayerPawn Victims[16];
var SoloRocket S;

function PreBeginPlay() {
	if (bInitialised) {
		return;
	}

	Level.Game.BaseMutator.AddMutator(self);
	bInitialised = true;
}

function Mutate(string MutateString, PlayerPawn Sender) {
	local string     Action, NameSearch;
	local int        i;
	local PlayerPawn P;

	if (Sender.bAdmin) {

		SplitMutateString(MutateString, Action, NameSearch);

		if (Action ~= "Punish" && NameSearch != "") {

			foreach AllActors(Class'PlayerPawn', P) {
				if (
					NameSearch == P.PlayerReplicationInfo.PlayerName             ||
					Caps(NameSearch) == Caps(P.PlayerReplicationInfo.PlayerName) ||
					InStr(Caps(P.PlayerReplicationInfo.PlayerName), Caps(NameSearch)) != -1
				) {
					for (i = 0; i < ArrayCount(Victims); i++) {
						if (
							Victims[i] == none      &&            // Check for empty slot.

							// pointless check!
							i < ArrayCount(Victims) &&            // Make sure it's not the end of the array.
							!P.PlayerReplicationInfo.bIsSpectator // Spectators are exempt from punishment.
						) {
							Victims[i] = P;
							break;
						}
					}
					break;
				}
			}

			SetTimer(0.3, true);
		}

		// They've atoned - release them from the array.
		else if (Action ~= "PunishEnd") {
			for (i = 0; i < ArrayCount(Victims); i++) {
				Victims[i] = none;
			}
		}

	}

	if (NextMutator != none) {
		NextMutator.Mutate(MutateString, Sender);
	}
}

function SplitMutateString(String mString, out String action, out string param1) {
	if (InStr(mString, " ") != -1) {
		action = Left(mString, InStr(mString, " "));
		param1 = Caps(Right(mString, Len(mString) - InStr(mString, " ") - 1));
	} else {
		action = mString;
	}
}

function Timer() {
	local int i;

	for (i = 0; i < ArrayCount(Victims); i++) {
		if (Victims[i] == none) {
			break;
		} else {
			if (Victims[i].Health > 0) {
				// Try spawning above the player.
				S = Spawn(Class'SoloRocket',,, Victims[i].Location + 160 * Vect(0, 0, 1), Rotator(Vect(0, 0, -1)));

				// Player might be in a narrow space - try spawning in a few different directions.
				if (S == none) {
					S = Spawn(Class'SoloRocket',,, Victims[i].Location + 160 * Vect(0, 0, -1), Rotator(Vect(0, 0, 1)));

					if (S == none) {
						S = Spawn(Class'SoloRocket',,, Victims[i].Location + 160 * Vect(0, -1, 0), Rotator(Vect(0, 1, 0)));

						if (S == none) {
							S = Spawn(Class'SoloRocket',,, Victims[i].Location + 160 * Vect(0, 1, 0), Rotator(Vect(0, -1, 0)));

							if (S == none) {
								S = Spawn(Class'SoloRocket',,, Victims[i].Location + 160 * Vect(-1, 0, 0), Rotator(Vect(1, 0, 0)));

								if (S == none) {
									S = Spawn(Class'SoloRocket',,, Victims[i].Location + 160 * Vect(1, 0, 0), Rotator(Vect(-1, 0, 0)));
								}
							}
						}
					}
				}

				if (S != none) {
					S.Sinner = Victims[i].PlayerReplicationInfo.PlayerName;
				}
			}
		}
	}
}