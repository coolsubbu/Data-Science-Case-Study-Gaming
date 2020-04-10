
#!usr/bin/perl
use DBI;
use JSON

open(CONFIG,"<","CONFIG.JSON") or die "cant open config json file"



$config=decode_json(<CONFIG>)

$dbh=DBI->connect('DBI:mysql:kabam',$config->{"DB"}->{'usr'},$config->{"DB"}->{"pw"}) or die "connection error: $DBI:errstr\n";
$location=$config->{"DATAFolder"}

#AIM: To study and upload the data for the users stats , alliance stats and Location Stats.

open(USERDATA,"<$location./attacks_2.txt") or die "cant open the file $!";    
my @array=<USERDATA>;
my $score;
my %userHash;
my %allianceHash;
my $SDEFENCEuser;
my $SATTACKuser;
my $SDEFENCEalliance;
my $SATTACKalliance;
my $result;
my $i=0;
my $i=0;
my $j=0;
my $line;
my $SDEFENCEX;
my $SDEFENCEY;
my $SATTACKX;
my $SATTACKY;
my $SDEFENCEindex;
my $SATTACKindex;
my @reportbits;
my %LocationScore;
my $SATTACKKidLvl;

#might power of various troops as per given data 
my %might;
$might{'u1'}=1;
$might{'u2'}=0;
$might{'u4'}=4;
$might{'u5'}=4;
$might{'u6'}=4;
$might{'u7'}=16;
$might{'u8'}=16;
$might{'u9'}=0;
$might{'u10'}=24;
$might{'u11'}=16;
$might{'u12'}=24;
$might{'u13'}=24;
$might{'u3'}=0;
$might{'u16'}=48;
$might{'u14'}=48;
$might{'u15'}=48;
$might{'u17'}=96;
$might{'u18'}=96;
$might{'u19'}=96;
$might{'u53'}=18;
$might{'u52'}=24;
$might{'u54'}=18;
$might{'u55'}=18;
$might{'u56'}=24;
$might{'u57'}=24;
$might{'u58'}=30;
$might{'u59'}=30;
$might{'u60'}=30;

#compute absolute log of numbers and add a sign for negative numbers  .. we take log to avoid overflow of numbers
sub abslog{
my ($num)=@_;
	if($num<0)
	{
		return -log(abs($num));
	}
	else
	{
		return log(1+$num);
	}
}

#Location initialization

#for($i=0;$i<800;$i++)
{
#	for($j=0;$j<800;$j++)
	{
#		$score[$i][$j]=0;
	}
}
my %LocationScore;

$LocationScore{100}=12;
$LocationScore{23}=234;

foreach $l (sort {$LocationScore{$a}>$LocationScore{$b}} keys(%LocationScore))
{
   my $x=$l/10;
   my $y=$l%10;
	print $l." :(x,y)=$x,$y and ".$LocationScore{$l}."\n";
} 


#Analytics from Attacks file.

for($i=0;$i<$#array;$i++)
{
	$line=$array[$i];
    #print $line;
	my @parts=split(/\t/,$line);
	
	$parts[13]=~s/\n//g;
	$SDEFENCEX=$parts[1];
	$SDEFENCEY=$parts[2];
	$SATTACKX=$parts[5];
	$SATTACKY=$parts[6];
	$SDEFENCEUser=$parts[3];
	$SATTACKUser=$parts[7];
	$SDEFENCEalliance=$parts[4]."|".$parts[13];
	$SATTACKalliance=$parts[8]."|".$parts[13];
	$result=$parts[9];
	$SATTACKLevel=$parts[11];
	
	#Obtaining Location Analytics
	$SDEFENCEindex=$SDEFENCEX*800+$SDEFENCEY;
	$SATTACKindex=$SATTACKX*800+$SATTACKY;
	$parts[12]=~s/"//g;
	#print "\n\nReport: $parts[12]";
	
	#Obtaining Report analytics
	@reportbits=split(/,/,$parts[12]);
	@kid0bts=split(":",$reportbits[0]);
	$SDEFENCEKid=$kid0bts[1];
	@kid1bts=split(":",$reportbits[1]);
	$SATTACKKid=$kid1bts[1];
	@kidLvlbts=split(":",$reportbits[2]);
	$SATTACKKidLvl=$kidLvlbts[1];
	@SDEFENCEcombatLvlbts=split(":",$reportbits[3]);
	$SDEFENCEcombatLvl=$SDEFENCEcombatLvlbts[1];
	@SATTACKcombatLvlbts=split(":",$reportbits[4]);
	$SATTACKcombatLvl=$SATTACKcombatLvlbts[1];
	@rndsbts=split(/rnds:/,$parts[12]);
	@rndsbits=split(/,/,$rndsbts[1]);
	$rnds=$rndsbits[0];
	@wallsbts=split(/wall:/,$parts[12]);
	@wallsbits=split(/,/,$wallsbts[1]);
	$wall=$wallsbits[0];
	@SDEFENCEAtkBSTsbts=split(/s0atkBoost:/,$parts[12]);
	@SDEFENCEAtkBSTsbits=split(/,/,$SDEFENCEAtkBSTsbts[1]);
	$SDEFENCEAtkBST=$SDEFENCEAtkBSTsbits[0];
	@SDEFENCEDefBSTsbts=split(/s0defBoost:/,$parts[12]);
	@SDEFENCEDefBSTsbits=split(/,/,$SDEFENCEDefBSTsbts[1]);
	$SDEFENCEDefBST=$SDEFENCEDefBSTsbits[0];
	@SATTACKAtkBSTsbts=split(/s1atkBoost:/,$parts[12]);
	@SATTACKAtkBSTsbits=split(/,/,$SATTACKAtkBSTsbts[1]);
	$SATTACKAtkBST=$SATTACKAtkBSTsbits[0];
	@SATTACKDefBSTsbts=split(/s1defBoost:/,$parts[12]);
	@SATTACKDefBSTsbits=split(/,/,$SATTACKDefBSTsbts[1]);
	$SATTACKDefBST=$SATTACKDefBSTsbits[0];
	
	#obtaining month and time. for instigating a predicate on u14 till u19 
	my $timestamp=$parts[10];
	my @dateparts=split(/\s/,$parts[10]);
	my @monthday=split(/-/,$dateparts[0]);
	my $month=$monthday[1];
	my $day=$monthday[2];
	my $t1212=0;
	print "\nThe month:$month and day:$day ";
	
	#Obtaining Loot Analytics
	my @lootbts=split(/loot:\[/,$parts[12]);
	my @lootbits=split(/,/,$lootbts[1]);
	my $lootGold=log(1+$lootbits[0])/log(10);
	my $lootFood=log(1+$lootbits[1])/log(10);
	my $lootWood=log(1+$lootbits[2])/log(10);
	my $lootOre=log(1+$lootbits[3])/log(10);
	my $lootStone=log(1+$lootbits[4])/log(10);
	

	#attach experience for the attacking Knight
	my $xp=0;
	if($parts[12]=~/xp:(\d+)\}/)
	{
		$xp=$1;
	}
 	#Location!Location!Location-provide statistics.
	#obtain sentiments from the comments
	
	my $SDEFENCEmightLost=0;
	my $SATTACKmightLost=0;
	my $SDEFENCEmight=0;
	my $SATTACKmight=0;
	if($parts[12]=~/s0:(.*?),s1:(.*?)},rnds:/)
	{
		my $SDEFENCEfghtparts=$1;
		my $SATTACKfghtparts=$2;
		
		if($SDEFENCEfghtparts=~/:/)
		{
			my @SDEFENCEfghtUs=split(/u/,$SDEFENCEfghtparts);
			my $j=0;
			
			for($j=1;$j<=$#S0fghtUs;$j++)
			{

				if($SDEFENCEfghtUs[$j]=~/(\d+):/)
				{
					my $us0=$1;
					if($us0<53)
					{
						if($SDEFENCEfghtUs[$j]=~/\d+:\[(\d+),(\d+),(\d+)\]/)
						{
							my $killed=$3;
							my $valuelost=$might{'u'.$us0}*$killed;
							$SDEFENCEmightLost=$SDEFENCEmightLost+$valuelost;
							$SDEFENCEmight=$SDEFENCEmight+$1*$might{'u'.$us0};
						}
					}
					else
					{
						if($SDEFENCEfghtUs[$j]=~/\d+:\[(\d+),(\d+)\]/)
						{
							my $killed=$1-$2;
							my $valuelost;
							if($us0>=14 && $us0<=19 && $month==12 && $day>=12) # Capture the condition based on the 12/12 for increased might for troops u14 till u19.
							{
								$valuelost=$might{'u'.$us0}*$killed*3/2;
							}
							else
							{
								$valuelost=$might{'u'.$us0}*$killed;
							}
							$SDEFENCEmightLost=$SDEFENCEmightLost+$valuelost;
						}					
					}
				}								
			}
		}
		if($SATTACKfghtparts=~/:/)
		{
			my @SATTACKfghtUs=split(/u/,$SATTACKfghtparts);
			my $j=0;
			for($j=0;$j<=$#S1fghtUs;$j++)
			{
				if($SATTACKfghtUs[$j]=~/(\d+):/)
				{
					my $us1=$1;
					
					if($us1<53)
					{
						if($SATTACKfghtUs[$j]=~/\d+:\[(\d+),(\d+),(\d+)\]/)
						{
							my $killed=$3;
							my $valuelost=$might{'u'.$us1}*$killed;
							$SATTACKmightLost=$SATTACKmightLost+$valuelost;
						}
					}
					else
					{
						if($SATTACKfghtUs[$j]=~/\d+:\[(\d+),(\d+)\]/)
						{
							my $killed=$1-$2;
							my $valuelost=$might{'u'.$us1}*$killed;
							$SATTACKmightLost=$SATTACKmightLost+$valuelost;
						}					
					}
				}
			}
		}
	}
	#Insert into database records
	if($SDEFENCEX=~/^\d+$/)
	{
	
		$SATTACKDefBST=sprintf("%.5f",$SATTACKDefBST);
		$SATTACKAtkBST=sprintf("%.5f",$SATTACKAtkBST);
		$SDEFENCEDefBST=sprintf("%.5f",$SDEFENCEDefBST);
		$SDEFENCEAtkBST=sprintf("%.5f",$SDEFENCEAtkBST);
		$SDEFENCEmight=sprintf("%.5f",$SDEFENCEmight);
		$SDEFENCEmightLost=sprintf("%.5f",$SDEFENCEmightLost);
		$SATTACKmight=sprintf("%.5f",$SATTACKmight);
		$SATTACKmightLost=sprintf("%.5f",$SATTACKmightLost);
		$lootFood=sprintf("%.5f",$lootFood);
		$lootWood=sprintf("%.5f",$lootWood);
		$lootGold=sprintf("%.5f",$lootGold);
		$lootOre=sprintf("%.5f",$lootOre);
		$lootStone=sprintf("%.5f",$lootStone);
		if($SATTACKLevel =~/^\s*$/)
		{
			$SATTACKLevel=0;
		}
		if($SDEFENCEKid =~/^\s*$/)
		{
			$SDEFENCEKid=0;
		}
		if($SATTACKKid =~/^\s*$/)
		{
			$SATTACKKid=0;
		}
		if($SDEFENCEcombatLvl=~/^\s*$/)
		{
			$SDEFENCEcombatLvl=0;
		}
		if($SATTACKcombatLvl =~/^\s*$/)
		{
			$SATTACKcombatLvl=0;
		} 
		if($wall =~/^\s*$/)
		{
			$wall=0;
		}
		if($rnds=~/^\s*$/)
		{
			$rnds=0;
		}
		if($lootGold =~/^\s*$/)
		{
			$lootGold=0;
		}		
		if($lootFood =~/^\s*$/)
		{
			$lootFood=0;
		}
		if($lootWood =~/^\s*$/)
		{
			$lootWood=0;
		}
		if($lootOre =~/^\s*$/)
		{
			$lootOre=0;
		}
		if($lootStone =~/^\s*$/)
		{
			$lootStone=0;
		}		
		if($xp =~/^\s*$/)
		{
			$xp=0;
		} 
		$sql="insert into attacks(`S0X`,`S0Y`,`S0UserID`,`S0AllianceID`,`S1X`,`S1Y`,`S1UserID`,`S1AllianceID`,`Result`,`Timestamp`,`S1Level`,`S0Kid`,`S1Kid`,`S1KLv`,`S0KCombatLv`,`S1KCombatLv`,`Rounds`,`Wall`,`S0AtkBoost`,`S0DefBoost`,`S1AtkBoost`,`S1DefBoost`,`LootGold`,`LootFood`,`LootWood`,`LootOre`,`LootStone`,`S0Might`,`S0MightLost`,`S1Might`,`S1MightLost`,`XP`)values(\'$SDEFENCEX\',\'$SDEFENCEY\',\'$SDEFENCEUser\',\'$SDEFENCEalliance\',\'$SATTACKX\',\'$SATTACKY\',\'$SATTACKUser\',\'$SATTACKalliance\',\'$result\',\'$timestamp\',\'$SATTACKLevel\',\'$SDEFENCEKid\',\'$SATTACKKid\',\'$SATTACKKidLvl\',\'$SDEFENCEcombatLvl\',\'$SATTACKcombatLvl\',\'$rnds\',\'$wall\',\'$SDEFENCEAtkBST\',\'$SDEFENCEDefBST\',\'$SATTACKAtkBST\',\'$SATTACKDefBST\',\'$lootGold\',\'$lootFood\',\'$lootWood\',\'$lootOre\',\'$lootStone\',\'$SDEFENCEmight\',\'$SDEFENCEmightLost\',\'$SATTACKmight\',\'$SATTACKmightLost\',\'$xp\')";
		$sth=$dbh->prepare($sql);
		#$sth->execute or die "SQL Error:$DBI:errstr\n";
	}
	
	#Compute  Scores
	
	#we assign 10 points for Gold,5 points for Food, 3 points for Wood, 2 points for Ore and 1 for Stone.

	my $lootScore=$lootGold*10-$lootFood*5-$lootWood*3-$lootOre*2-$lootStone;
	
	#The ratio of the Wall to rounds is the tenacity of the wall per round.Adds to the DefenceScores.
	#The S0might of the defence computed earlier adds to the score.
	#The Boosts taken by the enemy and their Combat level adds to the Defence score.
	#The Boosts taken by the Defence and their Combat level subtracts the Defence score.
	#Loots subtracts the Defence score.
	#The mightlost by the Defence subtracts the Defence Scores.
	#The mightlost of the enemy adds to the Defence Scores.
	#The Defence Scores are averaged across the matches

	my $DefenceScore=(($wall+1)/($rnds+1))+$SDEFENCEmight+($SATTACKAtkBST+$SATTACKDefBST+$SATTACKcombatLvl)*0.1+$SATTACKmightLost+$SDEFENCEcombatLvl;

	$DefenceScore=$DefenceScore-($SDEFENCEmightLost+$lootScore)*0.15-($SDEFENCEDefBST+$SDEFENCEAtkBST)*0.01;
	$DefenceScore=abslog(1+$DefenceScore);

	#The ratio of the Wall to rounds is the tenacity of the wall per round.Subtracts to the AttackScore.
	#The S1might of the Attack computed earlier adds to the score.
	#The Boosts taken by the Attackers and their Combat level subtracts to the Attack score.
	#The Boosts taken by the Defence and their Combat level adds the Attack score.
	#Loots adds to the Attack score.
	#The mightlost by the Defence adds the Attack Scores.
	#The mightlost of the Attackers subtracts to the Attack Scores.
	#experience gained by the attacker adds to the scores.
	#The Attack scores are averaged across the matches.
	my $AttackScore=$SATTACKmight+$xp+($SDEFENCEAtkBST+$SDEFENCEDefBST+$SDEFENCEcombatLvl)*0.1+$lootScore+$SDEFENCEmightLost+$SATTACKcombatLvl;
	$AttackScore=$AttackScore-(($wall+1)/($rnds+1))-($SATTACKAtkBST-$SATTACKDefBST)*0.01-$SATTACKmightLost*0.15;
	$AttackScore=abslog(1+$AttackScore);
	#The Knight scores are simply 10% of the Attack or Defence scores which accrues the Knight user.
	#The Knight scores are doubled if the user led to a win. It is halfed if he led the army to Lost.
	my $KnightDefScore=$DefenceScore/10;
	my $KnightAtkScore=$AttackScore/10;
	
	#Alliance Scores are summations of the user scores/counts in the atttack/defence and win/loss/draw category.
	
	#Location scores are simply log summations of the users scores in that particular locations.
	
	if($result==1)
	{	
		$DefenceScore=($DefenceScore)*0.25;
	    #User and Alliance Defence analytics
		
		if(!exists $userHash{$SDEFENCEUser})
		{
			$userHash{$SDEFENCEUser}{"LostCount"}=1;			
			$userHash{$SDEFENCEUser}{"DefenceScore"}=$DefenceScore;
			$userHash{$SDEFENCEUser}{"AvgDefenceScore"}=$DefenceScore;
			$userHash{$SDEFENCEUser}{"S0might"}=abslog(1+$SDEFENCEmight);
		}
		else
		{
			$userHash{$SDEFENCEUser}{"LostCount"}=$userHash{$SDEFENCEUser}{"LostCount"}+1;
			$userHash{$SDEFENCEUser}{"AvgDefenceScore"}=($DefenceScore+$userHash{$SDEFENCEUser}{"AvgDefenceScore"})/2;
			$userHash{$SDEFENCEUser}{"DefenceScore"}=($DefenceScore+$userHash{$SDEFENCEUser}{"DefenceScore"});
			$userHash{$SDEFENCEUser}{"S0might"}=($userHash{$SDEFENCEUser}{"S0might"}+abslog(1+$SDEFENCEmight))/2;
			
		}
		 
		if(!exists $allianceHash{$SDEFENCEalliance})
		{
			$allianceHash{$SDEFENCEalliance}{"LostCount"}=1;
			$allianceHash{$SDEFENCEalliance}{"DefenceScore"}=$DefenceScore;			 
		}
		else
		{
			$allianceHash{$SDEFENCEalliance}{"LostCount"}=$allianceHash{$SDEFENCEalliance}{"LostCount"}+1;
			$allianceHash{$SDEFENCEalliance}{"DefenceScore"}=$allianceHash{$SDEFENCEalliance}{"DefenceScore"}+$DefenceScore;			 
		}
		#User and Alliance Attack analytics
		if(!exists $userHash{$SATTACKUser})
		{
			$userHash{$SATTACKUser}{"WinCount"}=1;
			$userHash{$SATTACKUser}{"AttackScore"}=$AttackScore;
			$userHash{$SATTACKUser}{"AvgAttackScore"}=$AttackScore;
			$userHash{$SATTACKUser}{"S1might"}=abslog(1+$SATTACKmight);
		}
		else
		{
			$userHash{$SATTACKUser}{"WinCount"}=$userHash{$SATTACKUser}{"WinCount"}+1;
			$userHash{$SATTACKUser}{"AttackScore"}=$userHash{$SATTACKUser}{"AttackScore"}+$AttackScore;
			$userHash{$SATTACKUser}{"AvgAttackScore"}=($userHash{$SATTACKUser}{"AvgAttackScore"}+$AttackScore)/2;
			$userHash{$SATTACKUser}{"S1might"}=($userHash{$SATTACKUser}{"S1might"}+abslog(1+$SATTACKmight))/2;
		}		 
		if(!exists $allianceHash{$SATTACKalliance})
		{
			$allianceHash{$SATTACKalliance}{"WinCount"}=1;
			$allianceHash{$SATTACKalliance}{"AttackScore"}=$AttackScore;
			
		}
		else
		{
			$allianceHash{$SATTACKalliance}{"WinCount"}=$allianceHash{$SATTACKalliance}{"WinCount"}+1;
			$allianceHash{$SATTACKalliance}{"AttackScore"}=$AttackScore+$allianceHash{$SATTACKalliance}{"AttackScore"};
			
		}
		#Location Defence and Attack Analytics
		#The victory represents the matchstatus. 
		#The matchstatus with 2 are not considered.
		if(!exists $LocationScore{$SDEFENCEindex})
		{
			$LocationScore{$SDEFENCEindex}{"Lost"}=1;
			$LocationScore{$SDEFENCEindex}{"Def"}=abslog(1+$DefenceScore);
			$LocationScore{$SDEFENCEindex}{"might"}=abslog(1+$SDEFENCEmight);
			$LocationScore{$SDEFENCEindex}{"mightLost"}=abslog(1+$SDEFENCEmightLost);
		}
		else
		{
			$LocationScore{$SDEFENCEindex}{"Lost"}=$LocationScore{$SDEFENCEindex}{"Lost"}+1;
			$LocationScore{$SDEFENCEindex}{"Def"}=abslog(1+$DefenceScore)+$LocationScore{$SDEFENCEindex}{"Def"};
			$LocationScore{$SDEFENCEindex}{"might"}=$LocationScore{$SDEFENCEindex}{"might"}+abslog(1+$SDEFENCEmight);
			$LocationScore{$SDEFENCEindex}{"mightLost"}=$LocationScore{$SDEFENCEindex}{"mightLost"}+abslog(1+$SDEFENCEmightLost);

		}
		if(!exists $LocationScore{$SATTACKindex})
		{
			$LocationScore{$SATTACKindex}{"Win"}=1;
			$LocationScore{$SATTACKindex}{"Atk"}=abslog(1+$AttackScore);
			$LocationScore{$SATTACKindex}{"might"}=abslog(1+$SATTACKmight);
			$LocationScore{$SATTACKindex}{"mightLost"}=abslog(1+$SATTACKmightLost);
		}
		else
		{
			$LocationScore{$SATTACKindex}{"Win"}=$LocationScore{$SATTACKindex}{"Win"}+1;
			$LocationScore{$SATTACKindex}{"Atk"}=abslog(1+$AttackScore)+$LocationScore{$SATTACKindex}{"Atk"};
			$LocationScore{$SATTACKindex}{"might"}=$LocationScore{$SATTACKindex}{"might"}+abslog(1+$SATTACKmight);
			$LocationScore{$SATTACKindex}{"mightLost"}=$LocationScore{$SATTACKindex}{"mightLost"}+abslog(1+$SATTACKmightLost);
		}
		#Knight Analytics for Attack and Defence
		#User is the Knight who defended and Lost we half his Defence Score.
		if(!exists $userHash{$SDEFENCEKid})
		{
			$userHash{$SDEFENCEKid}{"Knight:LostCount"}=1;
			$userHash{$SDEFENCEKid}{"Knight:Def"}=0.5*$KnightDefScore;
		}
		else
		{
			$userHash{$SDEFENCEKid}{"Knight:LostCount"}=$userHash{$SDEFENCEKid}{"Knight:LostCount"}+1;
			$userHash{$SDEFENCEKid}{"Knight:Def"}=(0.5*$KnightDefScore+$userHash{$SDEFENCEKid}{"Knight:Def"});
		}
		#User is the Knight who Attacked and won we double his Defence Score.
		if(!exists $userHash{$SATTACKKid})
		{
			$userHash{$SATTACKKid}{"Knight:WinCount"}=1;
			$userHash{$SATTACKKid}{"Knight:Atk"}=2*$KnightAtkScore;
		}
		else
		{
			$userHash{$SATTACKKid}{"Knight:WinCount"}=$userHash{$SATTACKKid}{"Knight:WinCount"}+1;
			$userHash{$SATTACKKid}{"Knight:Atk"}=($userHash{$SATTACKKid}{"Knight:Atk"}+2*$KnightAtkScore);			
		}
	}
	else
	{
		if($result==0)
		{	
			$AttackScore=0.25*$AttackScore;
			#User And Alliance Defence Analytics
			if(!exists $userHash{$SDEFENCEUser})
			{
				$userHash{$SDEFENCEUser}{"WinCount"}=1;
				$userHash{$SDEFENCEUser}{"DefenceScore"}=$DefenceScore;
				$userHash{$SDEFENCEUser}{"AvgDefenceScore"}=$DefenceScore;
				$userHash{$SDEFENCEUser}{"S0might"}=abslog(1+$SDEFENCEmight);
			}
			else
			{
				$userHash{$SDEFENCEUser}{"WinCount"}=$userHash{$SDEFENCEUser}{"WinCount"}+1;
				$userHash{$SDEFENCEUser}{"AvgDefenceScore"}=($DefenceScore+$userHash{$SDEFENCEUser}{"AvgDefenceScore"})/2;
				$userHash{$SDEFENCEUser}{"DefenceScore"}=$DefenceScore+$userHash{$SDEFENCEUser}{"DefenceScore"};
				$userHash{$SDEFENCEUser}{"S0might"}=($userHash{$SDEFENCEUser}{"S0might"}+abslog(1+$SDEFENCEmight))/2;
			}
			if(!exists $allianceHash{$SDEFENCEalliance})
			{
				$allianceHash{$SDEFENCEalliance}{"WinCount"}=1;
				$allianceHash{$SDEFENCEalliance}{"DefenceScore"}=$DefenceScore;
			}
			else
			{
				$allianceHash{$SDEFENCEalliance}{"WinCount"}=$allianceHash{$SDEFENCEalliance}{"WinCount"}+1;
				$allianceHash{$SDEFENCEalliance}{"DefenceScore"}=$allianceHash{$SDEFENCEalliance}{"DefenceScore"}+$DefenceScore;
			}
			
			#User and Alliance Attack Analytics
			if(!exists $userHash{$SATTACKUser})
			{
				$userHash{$SATTACKUser}{"LostCount"}=1;
				$userHash{$SATTACKUser}{"AttackScore"}=$AttackScore;
				$userHash{$SATTACKUser}{"AvgAttackScore"}=$AttackScore;
				$userHash{$SATTACKUser}{"S1might"}=abslog(1+$SATTACKmight);
			}
			else
			{
				$userHash{$SATTACKUser}{"LostCount"}=$userHash{$SATTACKUser}{"LostCount"}+1;
				$userHash{$SATTACKUser}{"AvgAttackScore"}=($userHash{$SATTACKUser}{"AvgAttackScore"}+$AttackScore)/2;
				$userHash{$SATTACKUser}{"AttackScore"}=$userHash{$SATTACKUser}{"AttackScore"}+$AttackScore;
				$userHash{$SATTACKUser}{"S1might"}=($userHash{$SATTACKUser}{"S1might"}+abslog(1+$SATTACKmight))/2;
			}
			if(!exists $allianceHash{$SATTACKalliance})
			{
				$allianceHash{$SATTACKalliance}{"LostCount"}=1;			
				$allianceHash{$SATTACKalliance}{"AttackScore"}=$AttackScore;	
			}
			else
			{
				$allianceHash{$SATTACKalliance}{"LostCount"}=$allianceHash{$SATTACKalliance}{"LostCount"}+1;
				$allianceHash{$SATTACKalliance}{"AttackScore"}=$AttackScore+$allianceHash{$SATTACKalliance}{"AttackScore"};
			}
					 
			#Location Defence and Attack Analytics
			if(!exists $LocationScore{$SDEFENCEindex})
			{
				$LocationScore{$SDEFENCEindex}{"Win"}=1;
				$LocationScore{$SDEFENCEindex}{"Def"}=abslog(1+$DefenceScore);
				$LocationScore{$SDEFENCEindex}{"might"}=abslog(1+$SDEFENCEmight);
				$LocationScore{$SDEFENCEindex}{"mightLost"}=abslog(1+$SDEFENCEmightLost);
			}
			else
			{
				$LocationScore{$SDEFENCEindex}{"Win"}=$LocationScore{$SDEFENCEindex}{"Win"}+1;
				$LocationScore{$SDEFENCEindex}{"Def"}=abslog(1+$DefenceScore)+$LocationScore{$SDEFENCEindex}{"Def"};
				$LocationScore{$SDEFENCEindex}{"might"}=$LocationScore{$SDEFENCEindex}{"might"}+abslog(1+$SDEFENCEmight);
				$LocationScore{$SDEFENCEindex}{"mightLost"}=$LocationScore{$SDEFENCEindex}{"mightLost"}+abslog(1+$SDEFENCEmightLost);
			}
			if(!exists $LocationScore{$SATTACKindex})
			{
				$LocationScore{$SATTACKindex}{"Lost"}=1;
				$LocationScore{$SATTACKindex}{"Atk"}=abslog(1+$AttackScore);
				$LocationScore{$SATTACKindex}{"might"}=abslog(1+$SATTACKmight);
				$LocationScore{$SATTACKindex}{"mightLost"}=abslog(1+$SATTACKmightLost);
			}
			else
			{
				$LocationScore{$SATTACKindex}{"Lost"}=$LocationScore{$SATTACKindex}{"Lost"}+1;
				$LocationScore{$SATTACKindex}{"Atk"}=abslog(1+$AttackScore)+$LocationScore{$SATTACKindex}{"Atk"};
				$LocationScore{$SATTACKindex}{"might"}=$LocationScore{$SATTACKindex}{"might"}+abslog(1+$SATTACKmight);
				$LocationScore{$SATTACKindex}{"mightLost"}=$LocationScore{$SATTACKindex}{"mightLost"}+abslog(1+$SATTACKmightLost);
			}
			
			#Knight Analytics for Attack and Defence
			#User is the Knight who attacked and Lost we half his AttackScore
			if(!exists $userHash{$SATTACKKid})
			{
				$userHash{$SATTACKKid}{"Knight:LostCount"}=1;
				$userHash{$SATTACKKid}{"Knight:Atk"}=0.5*$KnightAtkScore;
			}
			else
			{
				$userHash{$SATTACKKid}{"Knight:LostCount"}=$userHash{$SATTACKKid}{"Knight:LostCount"}+1;
				$userHash{$SATTACKKid}{"Knight:Atk"}=($userHash{$SATTACKKid}{"Knight:Atk"}+0.5*$KnightAtkScore);
			}
			#User is the Knight who defended and Won :: double the Defending points
			if(!exists $userHash{$SDEFENCEKid})
			{
				$userHash{$SDEFENCEKid}{"Knight:WinCount"}=1;
				$userHash{$SDEFENCEKid}{"Knight:Def"}=2*$KnightDefScore;
			}
			else
			{
				$userHash{$SDEFENCEKid}{"Knight:WinCount"}=$userHash{$SDEFENCEKid}{"Knight:WinCount"}+1;
				$userHash{$SDEFENCEKid}{"Knight:Def"}=(2*$KnightDefScore+$userHash{$SDEFENCEKid}{"Knight:Def"});
			}
		}
		else #matchstatus is 2
		{
			#for a war drawn, half the Defence and Attack scores 
			$AttackScore=0.5*$AttackScore;
			$DefenceScore=0.5*$DefenceScore;
			#User And Alliance Defence Analytics
			if(!exists $userHash{$SDEFENCEUser})
			{
				$userHash{$SDEFENCEUser}{"DrawCount"}=1;
				$userHash{$SDEFENCEUser}{"DefenceScore"}=$DefenceScore;
				$userHash{$SDEFENCEUser}{"AvgDefenceScore"}=$DefenceScore;
				$userHash{$SDEFENCEUser}{"S0might"}=abslog(1+$SDEFENCEmight);
			}
			else
			{
				$userHash{$SDEFENCEUser}{"DrawCount"}=$userHash{$SDEFENCEUser}{"DrawCount"}+1;
				$userHash{$SDEFENCEUser}{"AvgDefenceScore"}=($userHash{$SDEFENCEUser}{"AvgDefenceScore"}+$DefenceScore)/2;
				$userHash{$SDEFENCEUser}{"DefenceScore"}=$userHash{$SDEFENCEUser}{"DefenceScore"}+$DefenceScore;
				$userHash{$SDEFENCEUser}{"S0might"}=($userHash{$SDEFENCEUser}{"S0might"}+abslog(1+$SDEFENCEmight))/2;
			}
			if(!exists $allianceHash{$SDEFENCEalliance})
			{
				$allianceHash{$SDEFENCEalliance}{"DrawCount"}=1;
				$allianceHash{$SDEFENCEalliance}{"DefenceScore"}=$DefenceScore;
			}
			else
			{
				$allianceHash{$SDEFENCEalliance}{"DrawCount"}=$allianceHash{$SDEFENCEalliance}{"DrawCount"}+1;
				$allianceHash{$SDEFENCEalliance}{"DefenceScore"}=$allianceHash{$SDEFENCEalliance}{"DefenceScore"}+$DefenceScore;
			}
			
			#User and Alliance Attack Analytics
			if(!exists $userHash{$SATTACKUser})
			{
				$userHash{$SATTACKUser}{"DrawCount"}=1;
				$userHash{$SATTACKUser}{"AttackScore"}=$AttackScore;
				$userHash{$SATTACKUser}{"AvgAttackScore"}=$AttackScore;
				$userHash{$SATTACKUser}{"S1might"}=abslog(1+$SATTACKmight);
			}
			else
			{
				$userHash{$SATTACKUser}{"DrawCount"}=$userHash{$SATTACKUser}{"DrawCount"}+1;
				$userHash{$SATTACKUser}{"AvgAttackScore"}=($userHash{$SATTACKUser}{"AvgAttackScore"}+$AttackScore)/2;
				$userHash{$SATTACKUser}{"AttackScore"}=$userHash{$SATTACKUser}{"AttackScore"}+$AttackScore;
				$userHash{$SATTACKUser}{"S1might"}=($userHash{$SATTACKUser}{"S1might"}+abslog(1+$SATTACKmight))/2;
			}
			if(!exists $allianceHash{$SATTACKalliance})
			{
				$allianceHash{$SATTACKalliance}{"DrawCount"}=1;				
				$allianceHash{$SATTACKalliance}{"AttackScore"}=$AttackScore;
			}
			else
			{
				$allianceHash{$SATTACKalliance}{"DrawCount"}=$allianceHash{$SATTACKalliance}{"DrawCount"}+1;
				$allianceHash{$SATTACKalliance}{"AttackScore"}=$allianceHash{$SATTACKalliance}{"AttackScore"}+$AttackScore;
			}
					 
			#Location Defence and Attack Analytics
			if(!exists $LocationScore{$SDEFENCEindex})
			{
				#To avoid Negative Log we take the log of abs value and add a sign.
				 
				$LocationScore{$SDEFENCEindex}{"Draw"}=1;
				$LocationScore{$SDEFENCEindex}{"Def"}=abslog(1+$DefenceScore);
				$LocationScore{$SDEFENCEindex}{"might"}=abslog(1+$SDEFENCEmight);
				$LocationScore{$SDEFENCEindex}{"mightLost"}=abslog(1+$SDEFENCEmightLost);

			}
			else
			{
				#To avoid Negative Log we take the log of abs value and add a sign.
				my $Logval;
				$LocationScore{$SDEFENCEindex}{"Draw"}=$LocationScore{$SDEFENCEindex}{"Draw"}+1;
				$LocationScore{$SDEFENCEindex}{"Def"}=abslog(1+$DefenceScore)+$LocationScore{$SDEFENCEindex}{"Def"};
				$LocationScore{$SDEFENCEindex}{"might"}=$LocationScore{$SDEFENCEindex}{"might"}+abslog(1+$SDEFENCEmight);
				$LocationScore{$SDEFENCEindex}{"mightLost"}=$LocationScore{$SDEFENCEindex}{"mightLost"}+abslog(1+$SDEFENCEmightLost);
			}
			if(!exists $LocationScore{$SATTACKindex})
			{
				$LocationScore{$SATTACKindex}{"Draw"}=1;
				$LocationScore{$SATTACKindex}{"Atk"}=abslog(1+$AttackScore);
				$LocationScore{$SATTACKindex}{"might"}=abslog(1+$SATTACKmight);
				$LocationScore{$SATTACKindex}{"mightLost"}=abslog(1+$SATTACKmightLost);

			}
			else
			{
				$LocationScore{$SATTACKindex}{"Draw"}=$LocationScore{$SATTACKindex}{"Draw"}+1;
				$LocationScore{$SATTACKindex}{"Atk"}=abslog(1+$AttackScore)+$LocationScore{$SATTACKindex}{"Atk"};
				$LocationScore{$SATTACKindex}{"might"}=$LocationScore{$SATTACKindex}{"might"}+abslog(1+$SATTACKmight);
				$LocationScore{$SATTACKindex}{"mightLost"}=$LocationScore{$SATTACKindex}{"mightLost"}+abslog(1+$SATTACKmightLost);
			}
			
			#Knight Analytics for a drawn fight
			#Knight Analytics for Attack and Defence
			#User is the Knight who defended and Lost
			if(!exists $userHash{$SDEFENCEKid})
			{
				$userHash{$SDEFENCEKid}{"Knight:DrawCount"}=1;
				$userHash{$SDEFENCEKid}{"Knight:Def"}=$KnightDefScore;
			}
			else
			{
				$userHash{$SDEFENCEKid}{"Knight:DrawCount"}=$userHash{$SDEFENCEKid}{"Knight:DrawCount"}+1;
				$userHash{$SDEFENCEKid}{"Knight:Def"}=($KnightDefScore+$userHash{$SDEFENCEKid}{"Knight:Def"});
			}
			if(!exists $userHash{$SATTACKKid})
			{
				$userHash{$SATTACKKid}{"Knight:DrawCount"}=1;
				$userHash{$SATTACKKid}{"Knight:Atk"}=$KnightAtkScore;
			}
			else
			{
				$userHash{$SATTACKKid}{"Knight:DrawCount"}=$userHash{$SATTACKKid}{"Knight:DrawCount"}+1;
				$userHash{$SATTACKKid}{"Knight:Atk"}=($userHash{$SATTACKKid}{"Knight:Atk"}+$KnightAtkScore);			
			}
		}
	}
}

#Upload User Statistics

my $k=0;
 foreach $line (sort {$userHash{$a}{"WinCount"}>$userHash{$b}{"WinCount"}} keys %userHash)
 {
	if($line=~/^\d+$/)
	{
		$k=$k+1;
		my $Total_Perf=0;
		if(!exists $userHash{$line}{"WinCount"})
		{
			$userHash{$line}{"WinCount"}=0;
		}
		if(!exists $userHash{$line}{"LostCount"})
		{
			$userHash{$line}{"LostCount"}=0;
		}
		if(!exists $userHash{$line}{"DrawCount"})
		{
			$userHash{$line}{"DrawCount"}=0;
		}
		if(!exists $userHash{$line}{"Knight:WinCount"})
		{
			$userHash{$line}{"Knight:WinCount"}=0;
		}
		if(!exists $userHash{$line}{"Knight:LostCount"})
		{
			$userHash{$line}{"Knight:LostCount"}=0;
		}
		if(!exists $userHash{$line}{"Knight:DrawCount"})
		{
			$userHash{$line}{"Knight:DrawCount"}=0;
		}
		if(!exists $userHash{$line}{"Knight:Def"})
		{
			$userHash{$line}{"Knight:Def"}=0;
		}
		if(!exists $userHash{$line}{"Knight:Atk"})
		{
			$userHash{$line}{"Knight:Atk"}=0;
		}
		if(!exists $userHash{$line}{"DefenceScore"})
		{
			$userHash{$line}{"DefenceScore"}=0;
		}
		if(!exists $userHash{$line}{"AttackScore"})
		{
			$userHash{$line}{"AttackScore"}=0;
		} 
		if(!exists $userHash{$line}{"AvgDefenceScore"})
		{
			$userHash{$line}{"AvgDefenceScore"}=0;
		}
		if(!exists $userHash{$line}{"AvgAttackScore"})
		{
			$userHash{$line}{"AvgAttackScore"}=0;
		} 
		if(!exists $userHash{$line}{"S0might"})
		{
			$userHash{$line}{"S0might"}=0;
		} 
		if(!exists $userHash{$line}{"S1might"})
		{
			$userHash{$line}{"S1might"}=0;
		} 		
		$userHash{$line}{"DefenceScore"}=sprintf("%.5f",$userHash{$line}{"DefenceScore"});
		$userHash{$line}{"AttackScore"}=sprintf("%.5f",$userHash{$line}{"AttackScore"});
		$userHash{$line}{"AvgDefenceScore"}=sprintf("%.5f",$userHash{$line}{"AvgDefenceScore"});
		$userHash{$line}{"AvgAttackScore"}=sprintf("%.5f",$userHash{$line}{"AvgAttackScore"});
		$userHash{$line}{"Knight:Def"}=sprintf("%.5f",$userHash{$line}{"Knight:Def"});
		$userHash{$line}{"Knight:Atk"}=sprintf("%.5f",$userHash{$line}{"Knight:Atk"});
	 	$userHash{$line}{"S0might"}=sprintf("%.5f",$userHash{$line}{"S0might"});
		$userHash{$line}{"S1might"}=sprintf("%.5f",$userHash{$line}{"S1might"});
	 
		$lootFood=sprintf("%.5f",$lootFood);
		$lootWood=sprintf("%.5f",$lootWood);
		$lootGold=sprintf("%.5f",$lootGold);
		$lootOre=sprintf("%.5f",$lootOre);
		$lootStone=sprintf("%.5f",$lootStone);

		$sql="insert into user_perf3(`UserID`,`WinCount`,`LostCount`,`DrawCount`,`DefenceScore`,`AttackScore`,`AvgDefenceScore`,`AvgAttackScore`,`KnightWinCount`,`KnightLostCount`,`KnightDrawCount`,`KnightDefScore`,`KnightAtkScore`,`S0Might`,`S1Might`)values(\'$line\',\'".$userHash{$line}{"WinCount"}."\',\'".$userHash{$line}{"LostCount"}."\',\'".$userHash{$line}{"DrawCount"}."\',\'".$userHash{$line}{"DefenceScore"}."\',\'".$userHash{$line}{"AttackScore"}."\',\'".$userHash{$line}{"AvgDefenceScore"}."\',\'".$userHash{$line}{"AvgAttackScore"}."\',\'".$userHash{$line}{"Knight:WinCount"}."\',\'".$userHash{$line}{"Knight:LostCount"}."\',\'".$userHash{$line}{"Knight:DrawCount"}."\',\'".$userHash{$line}{"Knight:Def"}."\',\'".$userHash{$line}{"Knight:Atk"}."\',\'".$userHash{$line}{"S0might"}."\',\'".$userHash{$line}{"S1might"}."\')";
		#print $sql;
		$sth=$dbh->prepare($sql);
		$sth->execute or die "SQL Error:$DBI:errstr\n";
	}
 }
 
 #Upload Alliances Statistics
 
 my $j=0;
 foreach $line (sort {$allianceHash{$a}{"WinCount"}>$allianceHash{$b}{"WinCount"}} keys %allianceHash)
 {
	if($line=~/^\d+|\d$/)
	{
		$j=$j+1;
		if(!exists $allianceHash{$line}{"WinCount"})
		{
			$allianceHash{$line}{"WinCount"}=0;
		}
		if(!exists $allianceHash{$line}{"LostCount"})
		{
			$allianceHash{$line}{"LostCount"}=0;
		}
		if(!exists $allianceHash{$line}{"DrawCount"})
		{
			$allianceHash{$line}{"DrawCount"}=0;
		}
		if(!exists $allianceHash{$line}{"DefenceScore"})
		{
			$allianceHash{$line}{"DefenceScore"}=0;
		}
		if(!exists $allianceHash{$line}{"AttackScore"})
		{
			$allianceHash{$line}{"AttackScore"}=0;
		} 
		$allianceHash{$line}{"DefenceScore"}=sprintf("%.5f",$allianceHash{$line}{"DefenceScore"});
		$allianceHash{$line}{"AttackScore"}=sprintf("%.5f",$allianceHash{$line}{"AttackScore"});
		
		$sql="insert into alliance_perf(`AllianceID`,`WinCount`,`LostCount`,`DrawCount`,`DefenceScore`,`AttackScore`)values(\'$line\',\'".$allianceHash{$line}{"WinCount"}."\',\'".$allianceHash{$line}{"LostCount"}."\',\'".$allianceHash{$line}{"DrawCount"}."\',\'".$allianceHash{$line}{"DefenceScore"}."\',\'".$allianceHash{$line}{"AttackScore"}."\')";
		
		$sth=$dbh->prepare($sql);
		$sth->execute or die "SQL Error:$DBI:errstr\n";
		
	}
 }

 #Upload Location statistics

 print LOCATIONPERF "\nLocationX\tLocationY\tLocation\tLostCount\tDrawCount\tWinCount\tDefenceScore\tAttackScore\tMight\tMightLost\n";

  my $p=0;
 foreach $line (sort {$LocationScore{$a}{"Win"}>$LocationScore{$b}{"Win"}} keys %LocationScore)
 {
	if($line=~/^\d+$/)
	{	
		$p=$p+1;
		my $x=int($line/800);
		my $y=$line%800;
	 
		if(!exists $LocationScore{$line}{"Win"})
		{
			$LocationScore{$line}{"Win"}=0;
		}
		if(!exists $LocationScore{$line}{"Lost"})
		{
			$LocationScore{$line}{"Lost"}=0;
		}
		if(!exists $LocationScore{$line}{"Draw"})
		{
			$LocationScore{$line}{"Draw"}=0;
		}
		if(!exists $LocationScore{$line}{"Def"})
		{
			$LocationScore{$line}{"Def"}=0;
		}
		if(!exists $LocationScore{$line}{"Atk"})
		{
			$LocationScore{$line}{"Atk"}=0;
		}
		$LocationScore{$line}{"Def"}=sprintf("%.5f",$LocationScore{$line}{"Def"});
		$LocationScore{$line}{"Atk"}=sprintf("%.5f",$LocationScore{$line}{"Atk"});
	
		$sql="insert into location_perf(`X`,`Y`,`Lost`,`Draw`,`Win`,`Defence`,`Attack`)values(\'$x\',\'$y\',\'".$LocationScore{$line}{"Win"}."\',\'".$LocationScore{$line}{"Def"}."\',\'".$LocationScore{$line}{"Atk"}."\')";
		$sth=$dbh->prepare($sql);
		$sth->execute or die "SQL Error:$DBI:errstr\n";
		print LOCATIONPERF.$x."\t".$y."\t".$line."\t".$LocationScore{$line}{"Lost"}."\t".$LocationScore{$line}{"Draw"}."\t".$LocationScore{$line}{"Win"}."\t".$LocationScore{$line}{"Def"}."\t".$LocationScore{$line}{"Atk"}."\t".$LocationScore{$line}{"might"}."\t".$LocationScore{$line}{"mightLost"}."\n";
		print "Location $p\n";
	}
 }
 
