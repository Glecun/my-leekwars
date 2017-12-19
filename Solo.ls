include("Solo_FonctionsPhases");

//#######################################################################
//#							Code Principal								#
//#######################################################################

//####################  Variables
//moi-même
var me = getLeek();
// On récupère l'ennemi le plus proche
var enemy = getNearestEnemy();
//on choisi une arme
var weapon = chooseWeapon();

//####################  Phase 1: Deplacement
moveUpToNearestEnemyUpToAreaWeaponOrChip(enemy,me);

//####################  Phase 2: Bonus
bonus(me);

//####################  Phase 3: Tir
shoot(enemy,me);

//####################  Phase 4: BonusLess
bonusLess(me);

//####################  Phase 5: Fuyons
moveAwayFromLeeks(getAliveEnemies());
