global profil = "SUPPORT";

global tank = 1;
global enemy = null;

global me = getLeek();
global MAX_LIFE = getLife();

global alliesLives;

global turn = 1;

team();

function chooseWeapon() {
	if (getWeapon() == null) { //Si pas d'arme
		setWeapon(WEAPON_MAGNUM);
	}
	return getWeapon();
}

global nbTour_SHIELD = 1;

function shield(leek) {
	// On utilise le bouclier tout les 4 tours
	if (nbTour_CURE != 0) {nbTour_SHIELD = nbTour_SHIELD - 1;}
	if (nbTour_SHIELD <= 0) {
		var chip = useChip(CHIP_SHIELD, leek);
		if (chip == USE_FAILED) {
			useChip(CHIP_SHIELD, leek);
		}
		nbTour_SHIELD = 4;
	}
}

global nbTour_CURE = 1;

function heal(leek) {
	// On utilise le heal tout les 2 tours si on a perdu de la vie
	if (nbTour_CURE != 0) {
		nbTour_CURE = nbTour_CURE - 1;
	}
	if (nbTour_CURE <= 0 and(MAX_LIFE - getLife()) >= 50) {
		useChip(CHIP_CURE, leek);
		nbTour_CURE = 2;
	}
}

global nbTour_PROTEIN = 1;

function boost(leek) {
	// On utilise le protein tout les 4 tours
	nbTour_PROTEIN = nbTour_PROTEIN - 1;
	if (nbTour_PROTEIN <= 0) {
		var chip = useChip(CHIP_PROTEIN, leek);
		nbTour_PROTEIN = 3;
	}
}

function attack() {
	var ret = null;
	if (getDistanceEnemyAreaWeaponOrChip(enemy, CHIP_SPARK) <= 0) {
		while (ret != USE_NOT_ENOUGH_TP and ret != USE_INVALID_POSITION) {
			ret = useWeapon(enemy);
			if (ret == USE_NOT_ENOUGH_TP or ret == USE_INVALID_POSITION or ret == USE_INVALID_COOLDOWN) {
				ret = useChip(CHIP_SPARK, enemy);
			}
			//Si on a tué l'enemi le plus près
			if (isAlive(enemy) == false) {
				enemy = getEnemy(); // on change d'enemi
			}
		}
	}
	return ret;
}

function getEnemy() {
	var msgs = listen();
	var N_enemy = null;
	for (var id: var msg in msgs) {
		if (isAlly(id) && isAlive(msg)) {
			N_enemy = msg;
		}
	}
	if (N_enemy == null) {
		N_enemy = getNearestEnemy();
		say(""+N_enemy);
	}
	return N_enemy;
}

function getTank() {
	var allies = getAllies();
	var life = 0;
	for (var id in allies) {
		if (getLife(id) > life) {
			tank = id;
			life = getLife(id);
		}
	}
}

function getAlliesLives() {
	var tab;
	for (var ally in getAllies()) {
		tab[ally] = getLife(ally);
	}
	return tab;

}

function getLessLifeAlly(tabAlliesLives) {
	var idAlly = null;
	var deltaLife = 0;
	for (var ally in getAllies()) {
		if (deltaLife < getLife(ally) - tabAlliesLives[ally]) {
			deltaLife = getLife(ally) - tabAlliesLives[ally];
			debug(deltaLife);
			idAlly = ally;
		}
	}
	return idAlly;
}

function getDistanceEnemyAreaWeaponOrChip(enemyTmp, weaponOrChip) {
	if (isChip(weaponOrChip)) {
		return getCellDistance(getCell(enemyTmp), getCell()) - getChipMaxScope(weaponOrChip);
	} else {
		return getCellDistance(getCell(enemyTmp), getCell()) - getWeaponMaxScope(weaponOrChip);
	}
}

function moveUpToNearestEnemyUpToAreaWeaponOrChip(enemyTmp, weapon) {
	var nbCellMove = getDistanceEnemyAreaWeaponOrChip(enemyTmp, weapon);
	if (!(nbCellMove < 0)) {
		moveToward(enemyTmp, nbCellMove);
	}
}

function team() {
	if (turn == 1) chooseWeapon();
	if (enemy == null or isDead(enemy)) {
		enemy = getEnemy();
	}
	if (profil == "ATTACK") {
		if (tank == null or isDead(tank)) {
			getTank();
		}
		if (tank == me) {
			profil = "TANK";
		} else {
			if (getDistance(getCell(), getCell(tank)) > 5) {
				moveToward(tank);
			} else {
				moveUpToNearestEnemyUpToAreaWeaponOrChip(enemy, WEAPON_MAGNUM);
			}
			shield(me);
			attack();
			moveAwayFrom(getNearestEnemy());
		}
	}
	if (profil == "SUPPORT") {
		if (tank == null or isDead(tank)) {
			getTank();
		}
		if (tank == me) {
			profil = "TANK";
		} else {
			if (turn == 1) {
				alliesLives = getAlliesLives();
			}
			heal(me);
			var allyHelp = getLessLifeAlly(alliesLives);
			if(allyHelp!=null){ allyHelp=tank;}
			debug("Allié "+ getName(allyHelp)+" en galère !");
			moveUpToNearestEnemyUpToAreaWeaponOrChip(allyHelp, CHIP_CURE);
			heal(allyHelp);
			shield(allyHelp);
			boost(allyHelp);
			moveAwayFrom(getNearestEnemy());
		}
	}
	if (profil == "TANK") {
		moveToward(enemy);
		heal(me);
		shield(me);
		attack();
	}
}
