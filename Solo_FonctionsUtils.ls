function isAllEnemiesDead(){
	return getEnemiesCount()==getDeadEnemiesCount();
}

function getDistanceEnemyAreaWeaponOrChip(enemy,me,weaponOrChip){
	if(isChip(weaponOrChip)){
		if(weaponOrChip==CHIP_SPARK){
			return getCellDistance(getCell(enemy), getCell(me))-getChipMaxScope(weaponOrChip);
		} else {
			return getPathLength(getCell(enemy), getCell(me))-getChipMaxScope(weaponOrChip)+1;
		}
	} else{
		debug(getPathLength(getCell(enemy), getCell(me))-getWeaponMaxScope(weaponOrChip));
		debug(getCellDistance(getCell(enemy), getCell(me))-getWeaponMaxScope(weaponOrChip));
		return getPathLength(getCell(enemy), getCell(me))-getWeaponMaxScope(weaponOrChip)+1;
	}
}
