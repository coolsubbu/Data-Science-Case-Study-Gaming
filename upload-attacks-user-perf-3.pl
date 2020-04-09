#!usr/bin/perl
use DBI;
$location="C:/Data"
$dbh=DBI->connect('DBI:mysql:kabam','root','root') or die "connection error: $DBI:errstr\n";
#AIM: To study and upload the data for the users stats , alliance stats and Location Stats.
open(USERDATA,"<$location./attacks_2.txt") or die "cant open the file $!";    
my @array=<USERDATA>;
my $score;
my %userHash;
my %allianceHash;
my $S0user;
my $S1user;
my $S0alliance;
my $S1alliance;
my $result;
my $i=0;
my $i=0;
my $j=0;
my $line;
my $S0X;
my $S0Y;
my $S1X;
my $S1Y;
my $S0index;
my $S1index;
my @reportbits;
my %LocationScore;
my $S1KidLvl;

#might power of various troops
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
	$S0X=$parts[1];
	$S0Y=$parts[2];
	$S1X=$parts[5];
	$S1Y=$parts[6];
	$S0User=$parts[3];
	$S1User=$parts[7];
	$S0alliance=$parts[4]."|".$parts[13];
	$S1alliance=$parts[8]."|".$parts[13];
	$result=$parts[9];
	$S1Level=$parts[11];
	
	#Obtaining Location Analytics
	$S0index=$S0X*800+$S0Y;
	$S1index=$S1X*800+$S1Y;
	$parts[12]=~s/"//g;
	#print "\n\nReport: $parts[12]";
	
	#Obtaining Report analytics
	@reportbits=split(/,/,$parts[12]);
	@kid0bts=split(":",$reportbits[0]);
	$S0Kid=$kid0bts[1];
	@kid1bts=split(":",$reportbits[1]);
	$S1Kid=$kid1bts[1];
	@kidLvlbts=split(":",$reportbits[2]);
	$S1KidLvl=$kidLvlbts[1];
	@S0combatLvlbts=split(":",$reportbits[3]);
	$S0combatLvl=$S0combatLvlbts[1];
	@S1combatLvlbts=split(":",$reportbits[4]);
	$S1combatLvl=$S1combatLvlbts[1];
	@rndsbts=split(/rnds:/,$parts[12]);
	@rndsbits=split(/,/,$rndsbts[1]);
	$rnds=$rndsbits[0];
	@wallsbts=split(/wall:/,$parts[12]);
	@wallsbits=split(/,/,$wallsbts[1]);
	$wall=$wallsbits[0];
	@S0AtkBSTsbts=split(/s0atkBoost:/,$parts[12]);
	@S0AtkBSTsbits=split(/,/,$S0AtkBSTsbts[1]);
	$S0AtkBST=$S0AtkBSTsbits[0];
	@S0DefBSTsbts=split(/s0defBoost:/,$parts[12]);
	@S0DefBSTsbits=split(/,/,$S0DefBSTsbts[1]);
	$S0DefBST=$S0DefBSTsbits[0];
	@S1AtkBSTsbts=split(/s1atkBoost:/,$parts[12]);
	@S1AtkBSTsbits=split(/,/,$S1AtkBSTsbts[1]);
	$S1AtkBST=$S1AtkBSTsbits[0];
	@S1DefBSTsbts=split(/s1defBoost:/,$parts[12]);
	@S1DefBSTsbits=split(/,/,$S1DefBSTsbts[1]);
	$S1DefBST=$S1DefBSTsbits[0];
	
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
	
	my $S0mightLost=0;
	my $S1mightLost=0;
	my $S0might=0;
	my $S1might=0;
	if($parts[12]=~/s0:(.*?),s1:(.*?)},rnds:/)
	{
		my $S0fghtparts=$1;
		my $S1fghtparts=$2;
		
		if($S0fghtparts=~/:/)
		{
			my @S0fghtUs=split(/u/,$S0fghtparts);
			my $j=0;
			
			for($j=1;$j<=$#S0fghtUs;$j++)
			{

				if($S0fghtUs[$j]=~/(\d+):/)
				{
					my $us0=$1;
					if($us0<53)
					{
						if($S0fghtUs[$j]=~/\d+:\[(\d+),(\d+),(\d+)\]/)
						{
							my $killed=$3;
							my $valuelost=$might{'u'.$us0}*$killed;
							$S0mightLost=$S0mightLost+$valuelost;
							$S0might=$S0might+$1*$might{'u'.$us0};
						}
					}
					else
					{
						if($S0fghtUs[$j]=~/\d+:\[(\d+),(\d+)\]/)
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
							$S0mightLost=$S0mightLost+$valuelost;
						}					
					}
				}								
			}
		}
		if($S1fghtparts=~/:/)
		{
			my @S1fghtUs=split(/u/,$S1fghtparts);
			my $j=0;
			for($j=0;$j<=$#S1fghtUs;$j++)
			{
				if($S1fghtUs[$j]=~/(\d+):/)
				{
					my $us1=$1;
					
					if($us1<53)
					{
						if($S1fghtUs[$j]=~/\d+:\[(\d+),(\d+),(\d+)\]/)
						{
							my $killed=$3;
							my $valuelost=$might{'u'.$us1}*$killed;
							$S1mightLost=$S1mightLost+$valuelost;
						}
					}
					else
					{
						if($S1fghtUs[$j]=~/\d+:\[(\d+),(\d+)\]/)
						{
							my $killed=$1-$2;
							my $valuelost=$might{'u'.$us1}*$killed;
							$S1mightLost=$S1mightLost+$valuelost;
						}					
					}
				}
			}
		}
	}
	#Insert into database records
	if($S0X=~/^\d+$/)
	{
	
		$S1DefBST=sprintf("%.5f",$S1DefBST);
		$S1AtkBST=sprintf("%.5f",$S1AtkBST);
		$S0DefBST=sprintf("%.5f",$S0DefBST);
		$S0AtkBST=sprintf("%.5f",$S0AtkBST);
		$S0might=sprintf("%.5f",$S0might);
		$S0mightLost=sprintf("%.5f",$S0mightLost);
		$S1might=sprintf("%.5f",$S1might);
		$S1mightLost=sprintf("%.5f",$S1mightLost);
		$lootFood=sprintf("%.5f",$lootFood);
		$lootWood=sprintf("%.5f",$lootWood);
		$lootGold=sprintf("%.5f",$lootGold);
		$lootOre=sprintf("%.5f",$lootOre);
		$lootStone=sprintf("%.5f",$lootStone);
		if($S1Level =~/^\s*$/)
		{
			$S1Level=0;
		}
		if($S0Kid =~/^\s*$/)
		{
			$S0Kid=0;
		}
		if($S1Kid =~/^\s*$/)
		{
			$S1Kid=0;
		}
		if($S0combatLvl=~/^\s*$/)
		{
			$S0combatLvl=0;
		}
		if($S1combatLvl =~/^\s*$/)
		{
			$S1combatLvl=0;
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
		$sql="insert into attacks(`S0X`,`S0Y`,`S0UserID`,`S0AllianceID`,`S1X`,`S1Y`,`S1UserID`,`S1AllianceID`,`Result`,`Timestamp`,`S1Level`,`S0Kid`,`S1Kid`,`S1KLv`,`S0KCombatLv`,`S1KCombatLv`,`Rounds`,`Wall`,`S0AtkBoost`,`S0DefBoost`,`S1AtkBoost`,`S1DefBoost`,`LootGold`,`LootFood`,`LootWood`,`LootOre`,`LootStone`,`S0Might`,`S0MightLost`,`S1Might`,`S1MightLost`,`XP`)values(\'$S0X\',\'$S0Y\',\'$S0User\',\'$S0alliance\',\'$S1X\',\'$S1Y\',\'$S1User\',\'$S1alliance\',\'$result\',\'$timestamp\',\'$S1Level\',\'$S0Kid\',\'$S1Kid\',\'$S1KidLvl\',\'$S0combatLvl\',\'$S1combatLvl\',\'$rnds\',\'$wall\',\'$S0AtkBST\',\'$S0DefBST\',\'$S1AtkBST\',\'$S1DefBST\',\'$lootGold\',\'$lootFood\',\'$lootWood\',\'$lootOre\',\'$lootStone\',\'$S0might\',\'$S0mightLost\',\'$S1might\',\'$S1mightLost\',\'$xp\')";
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
	my $DefenceScore=(($wall+1)/($rnds+1))+$S0might+($S1AtkBST+$S1DefBST+$S1combatLvl)*0.1+$S1mightLost+$S0combatLvl;
	$DefenceScore=$DefenceScore-($S0mightLost+$lootScore)*0.15-($S0DefBST+$S0AtkBST)*0.01;
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
	my $AttackScore=$S1might+$xp+($S0AtkBST+$S0DefBST+$S0combatLvl)*0.1+$lootScore+$S0mightLost+$S1combatLvl;
	$AttackScore=$AttackScore-(($wall+1)/($rnds+1))-($S1AtkBST-$S1DefBST)*0.01-$S1mightLost*0.15;
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
		
		if(!exists $userHash{$S0User})
		{
			$userHash{$S0User}{"LostCount"}=1;			
			$userHash{$S0User}{"DefenceScore"}=$DefenceScore;
			$userHash{$S0User}{"AvgDefenceScore"}=$DefenceScore;
			$userHash{$S0User}{"S0might"}=abslog(1+$S0might);
		}
		else
		{
			$userHash{$S0User}{"LostCount"}=$userHash{$S0User}{"LostCount"}+1;
			$userHash{$S0User}{"AvgDefenceScore"}=($DefenceScore+$userHash{$S0User}{"AvgDefenceScore"})/2;
			$userHash{$S0User}{"DefenceScore"}=($DefenceScore+$userHash{$S0User}{"DefenceScore"});
			$userHash{$S0User}{"S0might"}=($userHash{$S0User}{"S0might"}+abslog(1+$S0might))/2;
			
		}
		 
		if(!exists $allianceHash{$S0alliance})
		{
			$allianceHash{$S0alliance}{"LostCount"}=1;
			$allianceHash{$S0alliance}{"DefenceScore"}=$DefenceScore;			 
		}
		else
		{
			$allianceHash{$S0alliance}{"LostCount"}=$allianceHash{$S0alliance}{"LostCount"}+1;
			$allianceHash{$S0alliance}{"DefenceScore"}=$allianceHash{$S0alliance}{"DefenceScore"}+$DefenceScore;			 
		}
		#User and Alliance Attack analytics
		if(!exists $userHash{$S1User})
		{
			$userHash{$S1User}{"WinCount"}=1;
			$userHash{$S1User}{"AttackScore"}=$AttackScore;
			$userHash{$S1User}{"AvgAttackScore"}=$AttackScore;
			$userHash{$S1User}{"S1might"}=abslog(1+$S1might);
		}
		else
		{
			$userHash{$S1User}{"WinCount"}=$userHash{$S1User}{"WinCount"}+1;
			$userHash{$S1User}{"AttackScore"}=$userHash{$S1User}{"AttackScore"}+$AttackScore;
			$userHash{$S1User}{"AvgAttackScore"}=($userHash{$S1User}{"AvgAttackScore"}+$AttackScore)/2;
			$userHash{$S1User}{"S1might"}=($userHash{$S1User}{"S1might"}+abslog(1+$S1might))/2;
		}		 
		if(!exists $allianceHash{$S1alliance})
		{
			$allianceHash{$S1alliance}{"WinCount"}=1;
			$allianceHash{$S1alliance}{"AttackScore"}=$AttackScore;
			
		}
		else
		{
			$allianceHash{$S1alliance}{"WinCount"}=$allianceHash{$S1alliance}{"WinCount"}+1;
			$allianceHash{$S1alliance}{"AttackScore"}=$AttackScore+$allianceHash{$S1alliance}{"AttackScore"};
			
		}
		#Location Defence and Attack Analytics
		#The victory represents the matchstatus. 
		#The matchstatus with 2 are not considered.
		if(!exists $LocationScore{$S0index})
		{
			$LocationScore{$S0index}{"Lost"}=1;
			$LocationScore{$S0index}{"Def"}=abslog(1+$DefenceScore);
			$LocationScore{$S0index}{"might"}=abslog(1+$S0might);
			$LocationScore{$S0index}{"mightLost"}=abslog(1+$S0mightLost);
		}
		else
		{
			$LocationScore{$S0index}{"Lost"}=$LocationScore{$S0index}{"Lost"}+1;
			$LocationScore{$S0index}{"Def"}=abslog(1+$DefenceScore)+$LocationScore{$S0index}{"Def"};
			$LocationScore{$S0index}{"might"}=$LocationScore{$S0index}{"might"}+abslog(1+$S0might);
			$LocationScore{$S0index}{"mightLost"}=$LocationScore{$S0index}{"mightLost"}+abslog(1+$S0mightLost);

		}
		if(!exists $LocationScore{$S1index})
		{
			$LocationScore{$S1index}{"Win"}=1;
			$LocationScore{$S1index}{"Atk"}=abslog(1+$AttackScore);
			$LocationScore{$S1index}{"might"}=abslog(1+$S1might);
			$LocationScore{$S1index}{"mightLost"}=abslog(1+$S1mightLost);
		}
		else
		{
			$LocationScore{$S1index}{"Win"}=$LocationScore{$S1index}{"Win"}+1;
			$LocationScore{$S1index}{"Atk"}=abslog(1+$AttackScore)+$LocationScore{$S1index}{"Atk"};
			$LocationScore{$S1index}{"might"}=$LocationScore{$S1index}{"might"}+abslog(1+$S1might);
			$LocationScore{$S1index}{"mightLost"}=$LocationScore{$S1index}{"mightLost"}+abslog(1+$S1mightLost);
		}
		#Knight Analytics for Attack and Defence
		#User is the Knight who defended and Lost we half his Defence Score.
		if(!exists $userHash{$S0Kid})
		{
			$userHash{$S0Kid}{"Knight:LostCount"}=1;
			$userHash{$S0Kid}{"Knight:Def"}=0.5*$KnightDefScore;
		}
		else
		{
			$userHash{$S0Kid}{"Knight:LostCount"}=$userHash{$S0Kid}{"Knight:LostCount"}+1;
			$userHash{$S0Kid}{"Knight:Def"}=(0.5*$KnightDefScore+$userHash{$S0Kid}{"Knight:Def"});
		}
		#User is the Knight who Attacked and won we double his Defence Score.
		if(!exists $userHash{$S1Kid})
		{
			$userHash{$S1Kid}{"Knight:WinCount"}=1;
			$userHash{$S1Kid}{"Knight:Atk"}=2*$KnightAtkScore;
		}
		else
		{
			$userHash{$S1Kid}{"Knight:WinCount"}=$userHash{$S1Kid}{"Knight:WinCount"}+1;
			$userHash{$S1Kid}{"Knight:Atk"}=($userHash{$S1Kid}{"Knight:Atk"}+2*$KnightAtkScore);			
		}
	}
	else
	{
		if($result==0)
		{	
			$AttackScore=0.25*$AttackScore;
			#User And Alliance Defence Analytics
			if(!exists $userHash{$S0User})
			{
				$userHash{$S0User}{"WinCount"}=1;
				$userHash{$S0User}{"DefenceScore"}=$DefenceScore;
				$userHash{$S0User}{"AvgDefenceScore"}=$DefenceScore;
				$userHash{$S0User}{"S0might"}=abslog(1+$S0might);
			}
			else
			{
				$userHash{$S0User}{"WinCount"}=$userHash{$S0User}{"WinCount"}+1;
				$userHash{$S0User}{"AvgDefenceScore"}=($DefenceScore+$userHash{$S0User}{"AvgDefenceScore"})/2;
				$userHash{$S0User}{"DefenceScore"}=$DefenceScore+$userHash{$S0User}{"DefenceScore"};
				$userHash{$S0User}{"S0might"}=($userHash{$S0User}{"S0might"}+abslog(1+$S0might))/2;
			}
			if(!exists $allianceHash{$S0alliance})
			{
				$allianceHash{$S0alliance}{"WinCount"}=1;
				$allianceHash{$S0alliance}{"DefenceScore"}=$DefenceScore;
			}
			else
			{
				$allianceHash{$S0alliance}{"WinCount"}=$allianceHash{$S0alliance}{"WinCount"}+1;
				$allianceHash{$S0alliance}{"DefenceScore"}=$allianceHash{$S0alliance}{"DefenceScore"}+$DefenceScore;
			}
			
			#User and Alliance Attack Analytics
			if(!exists $userHash{$S1User})
			{
				$userHash{$S1User}{"LostCount"}=1;
				$userHash{$S1User}{"AttackScore"}=$AttackScore;
				$userHash{$S1User}{"AvgAttackScore"}=$AttackScore;
				$userHash{$S1User}{"S1might"}=abslog(1+$S1might);
			}
			else
			{
				$userHash{$S1User}{"LostCount"}=$userHash{$S1User}{"LostCount"}+1;
				$userHash{$S1User}{"AvgAttackScore"}=($userHash{$S1User}{"AvgAttackScore"}+$AttackScore)/2;
				$userHash{$S1User}{"AttackScore"}=$userHash{$S1User}{"AttackScore"}+$AttackScore;
				$userHash{$S1User}{"S1might"}=($userHash{$S1User}{"S1might"}+abslog(1+$S1might))/2;
			}
			if(!exists $allianceHash{$S1alliance})
			{
				$allianceHash{$S1alliance}{"LostCount"}=1;			
				$allianceHash{$S1alliance}{"AttackScore"}=$AttackScore;	
			}
			else
			{
				$allianceHash{$S1alliance}{"LostCount"}=$allianceHash{$S1alliance}{"LostCount"}+1;
				$allianceHash{$S1alliance}{"AttackScore"}=$AttackScore+$allianceHash{$S1alliance}{"AttackScore"};
			}
					 
			#Location Defence and Attack Analytics
			if(!exists $LocationScore{$S0index})
			{
				$LocationScore{$S0index}{"Win"}=1;
				$LocationScore{$S0index}{"Def"}=abslog(1+$DefenceScore);
				$LocationScore{$S0index}{"might"}=abslog(1+$S0might);
				$LocationScore{$S0index}{"mightLost"}=abslog(1+$S0mightLost);
			}
			else
			{
				$LocationScore{$S0index}{"Win"}=$LocationScore{$S0index}{"Win"}+1;
				$LocationScore{$S0index}{"Def"}=abslog(1+$DefenceScore)+$LocationScore{$S0index}{"Def"};
				$LocationScore{$S0index}{"might"}=$LocationScore{$S0index}{"might"}+abslog(1+$S0might);
				$LocationScore{$S0index}{"mightLost"}=$LocationScore{$S0index}{"mightLost"}+abslog(1+$S0mightLost);
			}
			if(!exists $LocationScore{$S1index})
			{
				$LocationScore{$S1index}{"Lost"}=1;
				$LocationScore{$S1index}{"Atk"}=abslog(1+$AttackScore);
				$LocationScore{$S1index}{"might"}=abslog(1+$S1might);
				$LocationScore{$S1index}{"mightLost"}=abslog(1+$S1mightLost);
			}
			else
			{
				$LocationScore{$S1index}{"Lost"}=$LocationScore{$S1index}{"Lost"}+1;
				$LocationScore{$S1index}{"Atk"}=abslog(1+$AttackScore)+$LocationScore{$S1index}{"Atk"};
				$LocationScore{$S1index}{"might"}=$LocationScore{$S1index}{"might"}+abslog(1+$S1might);
				$LocationScore{$S1index}{"mightLost"}=$LocationScore{$S1index}{"mightLost"}+abslog(1+$S1mightLost);
			}
			
			#Knight Analytics for Attack and Defence
			#User is the Knight who attacked and Lost we half his AttackScore
			if(!exists $userHash{$S1Kid})
			{
				$userHash{$S1Kid}{"Knight:LostCount"}=1;
				$userHash{$S1Kid}{"Knight:Atk"}=0.5*$KnightAtkScore;
			}
			else
			{
				$userHash{$S1Kid}{"Knight:LostCount"}=$userHash{$S1Kid}{"Knight:LostCount"}+1;
				$userHash{$S1Kid}{"Knight:Atk"}=($userHash{$S1Kid}{"Knight:Atk"}+0.5*$KnightAtkScore);
			}
			#User is the Knight who defended and Won :: double the Defending points
			if(!exists $userHash{$S0Kid})
			{
				$userHash{$S0Kid}{"Knight:WinCount"}=1;
				$userHash{$S0Kid}{"Knight:Def"}=2*$KnightDefScore;
			}
			else
			{
				$userHash{$S0Kid}{"Knight:WinCount"}=$userHash{$S0Kid}{"Knight:WinCount"}+1;
				$userHash{$S0Kid}{"Knight:Def"}=(2*$KnightDefScore+$userHash{$S0Kid}{"Knight:Def"});
			}
		}
		else #matchstatus is 2
		{
			#for a war drawn, half the Defence and Attack scores 
			$AttackScore=0.5*$AttackScore;
			$DefenceScore=0.5*$DefenceScore;
			#User And Alliance Defence Analytics
			if(!exists $userHash{$S0User})
			{
				$userHash{$S0User}{"DrawCount"}=1;
				$userHash{$S0User}{"DefenceScore"}=$DefenceScore;
				$userHash{$S0User}{"AvgDefenceScore"}=$DefenceScore;
				$userHash{$S0User}{"S0might"}=abslog(1+$S0might);
			}
			else
			{
				$userHash{$S0User}{"DrawCount"}=$userHash{$S0User}{"DrawCount"}+1;
				$userHash{$S0User}{"AvgDefenceScore"}=($userHash{$S0User}{"AvgDefenceScore"}+$DefenceScore)/2;
				$userHash{$S0User}{"DefenceScore"}=$userHash{$S0User}{"DefenceScore"}+$DefenceScore;
				$userHash{$S0User}{"S0might"}=($userHash{$S0User}{"S0might"}+abslog(1+$S0might))/2;
			}
			if(!exists $allianceHash{$S0alliance})
			{
				$allianceHash{$S0alliance}{"DrawCount"}=1;
				$allianceHash{$S0alliance}{"DefenceScore"}=$DefenceScore;
			}
			else
			{
				$allianceHash{$S0alliance}{"DrawCount"}=$allianceHash{$S0alliance}{"DrawCount"}+1;
				$allianceHash{$S0alliance}{"DefenceScore"}=$allianceHash{$S0alliance}{"DefenceScore"}+$DefenceScore;
			}
			
			#User and Alliance Attack Analytics
			if(!exists $userHash{$S1User})
			{
				$userHash{$S1User}{"DrawCount"}=1;
				$userHash{$S1User}{"AttackScore"}=$AttackScore;
				$userHash{$S1User}{"AvgAttackScore"}=$AttackScore;
				$userHash{$S1User}{"S1might"}=abslog(1+$S1might);
			}
			else
			{
				$userHash{$S1User}{"DrawCount"}=$userHash{$S1User}{"DrawCount"}+1;
				$userHash{$S1User}{"AvgAttackScore"}=($userHash{$S1User}{"AvgAttackScore"}+$AttackScore)/2;
				$userHash{$S1User}{"AttackScore"}=$userHash{$S1User}{"AttackScore"}+$AttackScore;
				$userHash{$S1User}{"S1might"}=($userHash{$S1User}{"S1might"}+abslog(1+$S1might))/2;
			}
			if(!exists $allianceHash{$S1alliance})
			{
				$allianceHash{$S1alliance}{"DrawCount"}=1;				
				$allianceHash{$S1alliance}{"AttackScore"}=$AttackScore;
			}
			else
			{
				$allianceHash{$S1alliance}{"DrawCount"}=$allianceHash{$S1alliance}{"DrawCount"}+1;
				$allianceHash{$S1alliance}{"AttackScore"}=$allianceHash{$S1alliance}{"AttackScore"}+$AttackScore;
			}
					 
			#Location Defence and Attack Analytics
			if(!exists $LocationScore{$S0index})
			{
				#To avoid Negative Log we take the log of abs value and add a sign.
				 
				$LocationScore{$S0index}{"Draw"}=1;
				$LocationScore{$S0index}{"Def"}=abslog(1+$DefenceScore);
				$LocationScore{$S0index}{"might"}=abslog(1+$S0might);
				$LocationScore{$S0index}{"mightLost"}=abslog(1+$S0mightLost);

			}
			else
			{
				#To avoid Negative Log we take the log of abs value and add a sign.
				my $Logval;
				$LocationScore{$S0index}{"Draw"}=$LocationScore{$S0index}{"Draw"}+1;
				$LocationScore{$S0index}{"Def"}=abslog(1+$DefenceScore)+$LocationScore{$S0index}{"Def"};
				$LocationScore{$S0index}{"might"}=$LocationScore{$S0index}{"might"}+abslog(1+$S0might);
				$LocationScore{$S0index}{"mightLost"}=$LocationScore{$S0index}{"mightLost"}+abslog(1+$S0mightLost);
			}
			if(!exists $LocationScore{$S1index})
			{
				$LocationScore{$S1index}{"Draw"}=1;
				$LocationScore{$S1index}{"Atk"}=abslog(1+$AttackScore);
				$LocationScore{$S1index}{"might"}=abslog(1+$S1might);
				$LocationScore{$S1index}{"mightLost"}=abslog(1+$S1mightLost);

			}
			else
			{
				$LocationScore{$S1index}{"Draw"}=$LocationScore{$S1index}{"Draw"}+1;
				$LocationScore{$S1index}{"Atk"}=abslog(1+$AttackScore)+$LocationScore{$S1index}{"Atk"};
				$LocationScore{$S1index}{"might"}=$LocationScore{$S1index}{"might"}+abslog(1+$S1might);
				$LocationScore{$S1index}{"mightLost"}=$LocationScore{$S1index}{"mightLost"}+abslog(1+$S1mightLost);
			}
			
			#Knight Analytics for a drawn fight
			#Knight Analytics for Attack and Defence
			#User is the Knight who defended and Lost
			if(!exists $userHash{$S0Kid})
			{
				$userHash{$S0Kid}{"Knight:DrawCount"}=1;
				$userHash{$S0Kid}{"Knight:Def"}=$KnightDefScore;
			}
			else
			{
				$userHash{$S0Kid}{"Knight:DrawCount"}=$userHash{$S0Kid}{"Knight:DrawCount"}+1;
				$userHash{$S0Kid}{"Knight:Def"}=($KnightDefScore+$userHash{$S0Kid}{"Knight:Def"});
			}
			if(!exists $userHash{$S1Kid})
			{
				$userHash{$S1Kid}{"Knight:DrawCount"}=1;
				$userHash{$S1Kid}{"Knight:Atk"}=$KnightAtkScore;
			}
			else
			{
				$userHash{$S1Kid}{"Knight:DrawCount"}=$userHash{$S1Kid}{"Knight:DrawCount"}+1;
				$userHash{$S1Kid}{"Knight:Atk"}=($userHash{$S1Kid}{"Knight:Atk"}+$KnightAtkScore);			
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
		print LOCATIONPERF $x."\t".$y."\t".$line."\t".$LocationScore{$line}{"Lost"}."\t".$LocationScore{$line}{"Draw"}."\t".$LocationScore{$line}{"Win"}."\t".$LocationScore{$line}{"Def"}."\t".$LocationScore{$line}{"Atk"}."\t".$LocationScore{$line}{"might"}."\t".$LocationScore{$line}{"mightLost"}."\n";
		print "Location $p\n";
	}
 }
 
