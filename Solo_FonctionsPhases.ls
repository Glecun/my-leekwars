include("Solo_FonctionsUtils");

global MAX_LIFE= getLife();

global enemy_temp=getNearestEnemy();
global life_enemy=getLife(enemy_temp);
global compte_tour=0;
global go_on_enemy=false;

function chooseWeapon(){
	if( getWeapon()==null ){ //Si pas d'arme
		setWeapon(WEAPON_MAGNUM); 	// On prend le magnum
	}
	return getWeapon();
}

//On avance jusqu'à l'enemi le plus proche à la limite de la porté de l'arme ou Chip sauf si il attaque un allié
function moveUpToNearestEnemyUpToAreaWeaponOrChip(enemy,me){
	var nbCellMove=getDistanceEnemyAreaWeaponOrChip(enemy,me,CHIP_SPARK);
	// Si il y a des Alliés
	if(getAlliesCount()>1){
		// Si un allié est plus pres de lui que moi
		var ally= getNearestAllyTo(enemy);
		if (getCellDistance(me, enemy)>getCellDistance(enemy, ally)){
			nbCellMove=getDistanceEnemyAreaWeaponOrChip(enemy,me,WEAPON_MAGNUM);
		}
		//END
	}
	//END
	// Si la vie de l'enemi ne baisse pas
	if(enemy!=enemy_temp){
		enemy_temp=getNearestEnemy();
		life_enemy=getLife(enemy_temp);
		compte_tour=0;
		go_on_enemy=false;
	} else{
		compte_tour= compte_tour+1;
	}
	if ((getTurn()>9 && compte_tour>2 && getLife(enemy)>life_enemy -15) or go_on_enemy){
		debug("Je m'approche'");
		go_on_enemy=true;
		nbCellMove=getDistanceEnemyAreaWeaponOrChip(enemy,me,WEAPON_MAGNUM);
	}
	if(compte_tour>2){
		enemy_temp=getNearestEnemy();
		life_enemy=getLife(enemy_temp);
		compte_tour=0;
	}
	//END
	if(!(nbCellMove<0)){
		moveToward(enemy,nbCellMove);
	}
}

function bonus(me){
	// On utilise le bouclier tout les 4 tours
	if(getCooldown(CHIP_SHIELD)==0){
		var chip = useChip(CHIP_SHIELD, me);
		if(chip==USE_FAILED){useChip(CHIP_SHIELD, me);}
	}
	
	// On utilise le heal tout les 2 tours si on a perdu de la vie
	if(getCooldown(CHIP_CURE)==0 and (MAX_LIFE-getLife())>=50){
		useChip(CHIP_CURE, me);
	}
	
	// On utilise le steroid tout les 4 tours
	if(getCooldown(CHIP_STEROID)==0){
		useChip(CHIP_STEROID, me);
	}
}

function bonusLess(me){
	// On utilise le heal tout les tours si on a perdu de la vie
	if(getCooldown(CHIP_BANDAGE)==0 and (MAX_LIFE-getLife())>=50){
		useChip(CHIP_BANDAGE, me);
	}
}

function shoot(enemy,me){
	var ret = null;
	if (getDistanceEnemyAreaWeaponOrChip(enemy,me,CHIP_SPARK)<=0){
		while(ret!=USE_NOT_ENOUGH_TP and ret!=USE_INVALID_POSITION ){
			ret = useWeapon(enemy);
			if(ret==USE_NOT_ENOUGH_TP or ret==USE_INVALID_POSITION or ret==USE_INVALID_COOLDOWN){
				ret = useChip(CHIP_SPARK, enemy);
			}
			//Si on a tué l'enemi le plus près
			if (isAlive(enemy)==false){
				enemy = getNearestEnemy(); // on change d'enemi
			}
			if(isAllEnemiesDead()){
				say('Yeaaah !');
				break;
			}
		}
	}
	return ret;
}
