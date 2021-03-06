--labels
--INSERT [dbo].[LabelsBase] ([id], [value], [comment], [module]) VALUES (683, N'Some reinforcements have arrived</p>', N'', 1)
--INSERT [dbo].[LabelsBase] ([id], [value], [comment], [module]) VALUES (684, N'<p>Three ships just arrived at your colony, coming from your old homeland. Their engines barely made the trip, and their captains report that more ships were sent to you, but only these three ships made it.</p><p>Perhaps a search commando should be sent out to find the missings ships and secure the cargo on them.</p>', N'', 1)

--delete from [LabelsBase] where id in (683,684)

SET IDENTITY_INSERT [dbo].[Quests] ON
INSERT [dbo].[Quests] ([id], [descriptionLabel], [isIntro], [isRandom], [hasScript], [script], [label]) VALUES (50, NULL, 1, 0, 1, N'Reinforcements.js', 683)
SET IDENTITY_INSERT [dbo].[Quests] OFF

INSERT [dbo].[ResearchQuestPrerequisites] ([SourceType], [SourceId], [TargetType], [TargetId]) VALUES (2, 1, 2, 50)

insert into  [Sagittarius].[dbo].[UserQuests]
select id, 
50,
0,
0
from Sagittarius.dbo.Users where id != 0 


--quests
--release binaries, JS, player 0 rename to ''

begin tran 

declare @maxShipId int;
select @maxShipId = max(id) from dbo.Ships;
--select @maxShipId;

with minColonies as (
	select 
		userId, min(id) as id
	from dbo.Colonies 
	group by Colonies.userId
), colonyData as (
	select 
		dbo.Colonies.userId
		,Colonies.starId
		,StarMap.position.STX as starX
		,StarMap.position.STY as starY
		,Colonies.planetId
		,planet.x 
		,planet.y 
	from dbo.Colonies 
	inner join minColonies on minColonies.id = dbo.Colonies.id
	inner join dbo.StarMap on StarMap.id = Colonies.starId
	inner join dbo.SolarSystemInstances as planet on planet.id = Colonies.planetId
), ships as (select 
	ROW_NUMBER() over (order by colonyData.userId) + @maxShipId as newShipId
	,userId
	,'Fighter' as name
	,starX,starY, x, y,
	100 as hitpoints ,20 as attack,20 as defense,  --,[hitpoints],[attack],[defense]
		2 as scanRange,  --,[scanRange]
		--geometry::STPolyFromText('POLYGON ((' + convert(varchar(15), [position].STX - 1) + ' ' + convert(varchar(15), [position].STY - 1) + ', ' + convert(varchar(15), [position].STX + 1) + ' ' + convert(varchar(15), [position].STY - 1) + ', ' + convert(varchar(15), [position].STX + 1) + ' ' + convert(varchar(15), [position].STY + 1) + ', ' + convert(varchar(15), [position].STX - 1) + ' ' + convert(varchar(15), [position].STY + 1) + ',' + convert(varchar(15), [position].STX - 1) + ' ' + convert(varchar(15), [position].STY - 1) + '))', 0),
		20 as max_hyper,120 as max_impuls,10 as hyper,30 as impuls,  --,[max_hyper],[max_impuls],[hyper],[impuls]
		0 as colonizer,		--,[colonizer]      
		1 as hullId,		--,[hullId]
	starId,	 --[systemId]
	1 as templateId,		--, templateId
	411 as objectId,  --objectId -currently scout	
		
		1 as versionId,--,[versionId]
      4 as energy,--,[energy]
      9 as crew,--,[crew]
      2 as cargoroom,--,[cargoroom]
      80 as fuelroom,--,[fuelroom]
      0 as population,--,[population]
      1 as shipHullsImage,--,[shipHullsImage]
      0 as refitCounter,--,[refitCounter]
      0 as shipStockVersionId,--,[shipStockVersionId]
      0 as shipModulesVersionId,--,[shipModulesVersionId]      
      0 as noMovementCounter--,[noMovementCounter]
	 from colonyData

) 
select * into #newShips from ships --where userId = 157;

insert into [dbo].[Ships](
	id,[userId],[name]
      ,[spaceX],[spaceY] ,[systemX],[systemY]
      ,[hitpoints],[attack],[defense]
      ,[scanRange]
      ,[max_hyper],[max_impuls],[hyper],[impuls]
      ,[colonizer]      
      ,[hullId]
      ,[systemId]
      ,templateId
      ,objectId
	  ,[versionId] 
	  ,[energy],[crew]
      ,[cargoroom] ,[fuelroom]
      ,[population]
      ,[shipHullsImage],[refitCounter],[shipStockVersionId] ,[shipModulesVersionId]
      ,[noMovementCounter])
select * from #newShips;
--delete from ships where id = 1075

insert into [Sagittarius].[dbo].[shipModules]
select	newShipId,9 as moduleId ,1 as posX,3 as posY,10,1 from #newShips union all --[shipId] ,[moduleId],[posX],[posY],[hitpoints],[active]
select	newShipId,1,2,2,10,1 from #newShips union all 
select	newShipId,2,2,3,10,1 from #newShips union all 
select	newShipId,5,2,4,10,1 from #newShips union all  --laser .  8 = cargo
select	newShipId,10,3,3,10,1 from #newShips;

drop table #newShips

-- fighter 2:
select @maxShipId = max(id) from dbo.Ships;
with minColonies as (
	select 
		userId, min(id) as id
	from dbo.Colonies 
	group by Colonies.userId
), colonyData as (
	select 
		dbo.Colonies.userId
		,Colonies.starId
		,StarMap.position.STX as starX
		,StarMap.position.STY as starY
		,Colonies.planetId
		,planet.x 
		,planet.y 
	from dbo.Colonies 
	inner join minColonies on minColonies.id = dbo.Colonies.id
	inner join dbo.StarMap on StarMap.id = Colonies.starId
	inner join dbo.SolarSystemInstances as planet on planet.id = Colonies.planetId
), ships as (select 
	ROW_NUMBER() over (order by colonyData.userId) + @maxShipId as newShipId
	,userId
	,'Fighter' as name
	,starX,starY, x, y,
	100 as hitpoints ,20 as attack,20 as defense,  --,[hitpoints],[attack],[defense]
		2 as scanRange,  --,[scanRange]
		--geometry::STPolyFromText('POLYGON ((' + convert(varchar(15), [position].STX - 1) + ' ' + convert(varchar(15), [position].STY - 1) + ', ' + convert(varchar(15), [position].STX + 1) + ' ' + convert(varchar(15), [position].STY - 1) + ', ' + convert(varchar(15), [position].STX + 1) + ' ' + convert(varchar(15), [position].STY + 1) + ', ' + convert(varchar(15), [position].STX - 1) + ' ' + convert(varchar(15), [position].STY + 1) + ',' + convert(varchar(15), [position].STX - 1) + ' ' + convert(varchar(15), [position].STY - 1) + '))', 0),
		20 as max_hyper,120 as max_impuls,10 as hyper,30 as impuls,  --,[max_hyper],[max_impuls],[hyper],[impuls]
		0 as colonizer,		--,[colonizer]      
		1 as hullId,		--,[hullId]
	starId,	 --[systemId]
	1 as templateId,		--, templateId
	411 as objectId,  --objectId -currently scout	
		
		1 as versionId,--,[versionId]
      4 as energy,--,[energy]
      9 as crew,--,[crew]
      2 as cargoroom,--,[cargoroom]
      80 as fuelroom,--,[fuelroom]
      0 as population,--,[population]
      1 as shipHullsImage,--,[shipHullsImage]
      0 as refitCounter,--,[refitCounter]
      0 as shipStockVersionId,--,[shipStockVersionId]
      0 as shipModulesVersionId,--,[shipModulesVersionId]      
      0 as noMovementCounter--,[noMovementCounter]
	 from colonyData

) 
select * into #newShips2 from ships-- where userId = 157;

insert into [dbo].[Ships](
	id,[userId],[name]
      ,[spaceX],[spaceY] ,[systemX],[systemY]
      ,[hitpoints],[attack],[defense]
      ,[scanRange]
      ,[max_hyper],[max_impuls],[hyper],[impuls]
      ,[colonizer]      
      ,[hullId]
      ,[systemId]
      ,templateId
      ,objectId
	  ,[versionId] 
	  ,[energy],[crew]
      ,[cargoroom] ,[fuelroom]
      ,[population]
      ,[shipHullsImage],[refitCounter],[shipStockVersionId] ,[shipModulesVersionId]
      ,[noMovementCounter])
select * from #newShips2;
--delete from ships where id = 1075

insert into [Sagittarius].[dbo].[shipModules]
select	newShipId,9 as moduleId ,1 as posX,3 as posY,10,1 from #newShips2 union all --[shipId] ,[moduleId],[posX],[posY],[hitpoints],[active]
select	newShipId,1,2,2,10,1 from #newShips2 union all 
select	newShipId,2,2,3,10,1 from #newShips2 union all 
select	newShipId,5,2,4,10,1 from #newShips2 union all  --laser .  8 = cargo
select	newShipId,10,3,3,10,1 from #newShips2;

drop table #newShips2

-- transporter 2:
select @maxShipId = max(id) from dbo.Ships;
with minColonies as (
	select 
		userId, min(id) as id
	from dbo.Colonies 
	group by Colonies.userId
), colonyData as (
	select 
		dbo.Colonies.userId
		,Colonies.starId
		,StarMap.position.STX as starX
		,StarMap.position.STY as starY
		,Colonies.planetId
		,planet.x 
		,planet.y 
	from dbo.Colonies 
	inner join minColonies on minColonies.id = dbo.Colonies.id
	inner join dbo.StarMap on StarMap.id = Colonies.starId
	inner join dbo.SolarSystemInstances as planet on planet.id = Colonies.planetId
), ships as (select 
	ROW_NUMBER() over (order by colonyData.userId) + @maxShipId as newShipId
	,userId
	,'Freighter' as name
	,starX,starY, x, y,
	100 as hitpoints ,0 as attack,0 as defense,  --,[hitpoints],[attack],[defense]
		2 as scanRange,  --,[scanRange]
		--geometry::STPolyFromText('POLYGON ((' + convert(varchar(15), [position].STX - 1) + ' ' + convert(varchar(15), [position].STY - 1) + ', ' + convert(varchar(15), [position].STX + 1) + ' ' + convert(varchar(15), [position].STY - 1) + ', ' + convert(varchar(15), [position].STX + 1) + ' ' + convert(varchar(15), [position].STY + 1) + ', ' + convert(varchar(15), [position].STX - 1) + ' ' + convert(varchar(15), [position].STY + 1) + ',' + convert(varchar(15), [position].STX - 1) + ' ' + convert(varchar(15), [position].STY - 1) + '))', 0),
		20 as max_hyper,120 as max_impuls,10 as hyper,30 as impuls,  --,[max_hyper],[max_impuls],[hyper],[impuls]
		0 as colonizer,		--,[colonizer]      
		1 as hullId,		--,[hullId]
	starId,	 --[systemId]
	1 as templateId,		--, templateId
	411 as objectId,  --objectId -currently scout	
		
		1 as versionId,--,[versionId]
      4 as energy,--,[energy]
      9 as crew,--,[crew]
      202 as cargoroom,--,[cargoroom]
      80 as fuelroom,--,[fuelroom]
      0 as population,--,[population]
      1 as shipHullsImage,--,[shipHullsImage]
      0 as refitCounter,--,[refitCounter]
      0 as shipStockVersionId,--,[shipStockVersionId]
      0 as shipModulesVersionId,--,[shipModulesVersionId]      
      0 as noMovementCounter--,[noMovementCounter]
	 from colonyData

) 
select * into #newShips3 from ships --where userId = 157;

insert into [dbo].[Ships](
	id,[userId],[name]
      ,[spaceX],[spaceY] ,[systemX],[systemY]
      ,[hitpoints],[attack],[defense]
      ,[scanRange]
      ,[max_hyper],[max_impuls],[hyper],[impuls]
      ,[colonizer]      
      ,[hullId]
      ,[systemId]
      ,templateId
      ,objectId
	  ,[versionId] 
	  ,[energy],[crew]
      ,[cargoroom] ,[fuelroom]
      ,[population]
      ,[shipHullsImage],[refitCounter],[shipStockVersionId] ,[shipModulesVersionId]
      ,[noMovementCounter])
select * from #newShips3;
--delete from ships where id = 1075

insert into [Sagittarius].[dbo].[shipModules]
select	newShipId,9 as moduleId ,1 as posX,3 as posY,10,1 from #newShips3 union all --[shipId] ,[moduleId],[posX],[posY],[hitpoints],[active]
select	newShipId,1,2,2,10,1 from #newShips3 union all 
select	newShipId,2,2,3,10,1 from #newShips3 union all 
select	newShipId,8,2,4,10,1 from #newShips3 union all  --5 = laser .  8 = cargo
select	newShipId,10,3,3,10,1 from #newShips3;


insert into [Sagittarius].[dbo].[shipStock]
select	newShipId as shipId,1 as goodsId ,100 as amount from #newShips3 union all --[shipId] ,[moduleId],[posX],[posY],[hitpoints],[active]
select	newShipId as shipId,2 as goodsId ,30 as amount from #newShips3 union all 
select	newShipId as shipId,10 as goodsId ,70 as amount from #newShips3


drop table #newShips3;





--CREATE DEBTRIS:

with goodPs as (
	select 0 as startV, 20 as endV, 1 as goodsId, 200 as amount union all   --building material
	select 20 , 40 , 2 , 200  union all  -- food
	select 40 , 60 , 10 , 120  union all  -- metal
	select 60 , 65 , 1040 , 60  union all  -- Holmium
	select 65 , 70 , 1041 , 60  union all  -- Terbium
	select 70 , 75 , 1042 , 60  union all  -- Scandium
	select 75 , 80 , 1043 , 60  union all  -- Yttrium
	select 80 , 85 , 1044 , 60  union all  -- Lutetium
	select 85 , 86 , 2001, 2 union all	--Crew I
	select 86 , 87 , 2002, 2 union all	--Reactor I
	select 87 , 88 , 2003, 2 union all	--Hull I
	select 88 , 89 , 2004, 2 union all	--Shield I
	select 89 , 90 , 2005, 2 union all	--Laser I
	select 90 , 91 , 2006, 2 union all	--Missile I
	select 91 , 92 , 2007, 2 union all	--Mass Driver I
	select 92 , 93 , 2008, 2 union all	--Cargo I
	select 93 , 94 , 2009, 2 union all	--System Engines I
	select 94 , 95 , 2010, 2 union all	--Hyper Engines I
	select 95 , 96 , 2011, 2 union all	--System Batteries I
	select 96 , 97 , 2012, 2 union all	--Hyper Batteries I
	select 97 , 98 , 2013, 1 union all	--Outpost Module
	select 98 , 99 , 3101, 1 union all --	Yttrium Crew I
	select 99 , 100, 3102, 1 union all --	Lutetium Reactor I
	select 100, 101, 3103, 1 union all --	Terbium Hull I
	select 101, 102, 3104, 1 union all --	Scandium Shield I
	select 102, 103, 3105, 1 union all --	Holmium Laser I
	select 103, 104, 3108, 1 union all --	Yttrium Cargo I
	select 104, 105, 3110, 1 union all --	Yttrium Hyper Engines I
	select 105, 106, 3115, 1  --	Lutetium Scanner I
)
select * 
into #goods
from goodPs;

--select * from #goods





select @maxShipId = max(id) + 1 from dbo.Ships;
--select @maxShipId;

with positions as (select 
	number + @maxShipId as id,
	((number / 60) * 10) + 4700 + [dbo].[randomFunc](9,0) as x,
	((number % 60) * 10) + 4700 + [dbo].[randomFunc](9,0)as y,
	[dbo].[randomFunc](105,0) as randomGoodId
from numbers where number < 3600)
select * 
into #positions 
from positions;

--select * from #positions where randomGoodId = 0;

--get Space Stations which are directly on the same tile as a star:
select 
 #positions.*
into #positionsToCorrect
from dbo.StarMap
inner join #positions
on  (StarMap.position.STX =  #positions.x and  StarMap.position.STY =  #positions.y);

--select * from #positionsToCorrect

--move Space Stations which are directly on the same tile as a star a bit 
update  #positions set x = #positions.x - 2 , y = #positions.y + 1 
from #positions 
inner join #positionsToCorrect
on #positionsToCorrect.id = #positions.id

insert into [dbo].[Ships](
	id,[userId],[name]
      ,[spaceX],[spaceY] ,[systemX],[systemY]
      ,[hitpoints],[attack],[defense]
      ,[scanRange]
      ,[max_hyper],[max_impuls],[hyper],[impuls]
      ,[colonizer]      
      ,[hullId]
      ,[systemId]
      ,templateId
      ,objectId
	  ,[versionId] 
	  ,[energy],[crew]
      ,[cargoroom] ,[fuelroom]
      ,[population]
      ,[shipHullsImage],[refitCounter],[shipStockVersionId] ,[shipModulesVersionId]
      ,[noMovementCounter])
select 
	#positions.id, 0, 'Debris',
	#positions.x, #positions.y, 0, 0
	,0,0,0
	,0
	,0,0,0,0 --speed
	,0
	,0 --hullId
	,null
	,0
	,440 --objectId
	,0
	,0,0
	,0,0
	,0
	,0,0,0,0  --[shipHullsImage],[refitCounter],[shipStockVersionId] ,[shipModulesVersionId]
	,0
from #positions

insert into [Sagittarius].[dbo].[shipStock]
select	
	#positions.id as shipId
--	,#positions.randomGoodId  
	,#goods.goodsId as goodsId 
	,#goods.amount as amount 
from #positions 
left join #goods 
	on #goods.startV <= #positions.randomGoodId and #goods.endV > #positions.randomGoodId


drop table #positionsToCorrect
drop table #positions
drop table #goods



commit tran


INSERT [dbo].[LabelsBase] ([id], [value], [comment], [module]) VALUES (684, N'<p>Three ships just arrived at your colony, coming from your old homeland. Their engines barely made the trip, and their captains report that more ships were sent to you, but only these three ships made it.</p><p>Perhaps a search commando should be sent out to find the missing ships and secure the cargo on them.</p>', N'', 1)

--delete from [LabelsBase] where id = 684

/*
with goodPs as (
select 0 as startV, 20 as endV, 1 as goodsId, 200 as amount union all   --bm
select 20 , 40 , 2 , 200  union all  -- food
select 40 , 60 , 10 , 120  union all  -- metal
select 60 , 65 , 1040 , 120  union all  -- Holmium
select 65 , 70 , 1041 , 120  union all  -- Terbium
select 70 , 75 , 1042 , 120  union all  -- Scandium
select 75 , 80 , 1043 , 120  union all  -- Yttrium
select 80 , 85 , 1044 , 120  union all  -- Lutetium
select 85 , 86 , 2001, 2 union all	--Crew I
select 86 , 87 , 2002, 2 union all	--Reactor I
select 87 , 88 , 2003, 2 union all	--Hull I
select 88 , 89 , 2004, 2 union all	--Shield I
select 89 , 90 , 2005, 2 union all	--Laser I
select 90 , 91 , 2006, 2 union all	--Missile I
select 91 , 92 , 2007, 2 union all	--Mass Driver I
select 92 , 93 , 2008, 2 union all	--Cargo I
select 93 , 94 , 2009, 2 union all	--System Engines I
select 94 , 95 , 2010, 2 union all	--Hyper Engines I
select 95 , 96 , 2011, 2 union all	--System Batteries I
select 96 , 97 , 2012, 2 union all	--Hyper Batteries I
select 97 , 98 , 2013, 1 union all	--Outpost Module
select 98 , 99 , 3101, 1 union all --	Yttrium Crew I
select 99 , 100, 3102, 1 union all --	Lutetium Reactor I
select 100, 101, 3103, 1 union all --	Terbium Hull I
select 101, 102, 3104, 1 union all --	Scandium Shield I
select 102, 103, 3105, 1 union all --	Holmium Laser I
select 103, 104, 3108, 1 union all --	Yttrium Cargo I
select 104, 105, 3110, 1 union all --	Yttrium Hyper Engines I
select 105, 106, 3115, 1  --	Lutetium Scanner I
)
select * 
into #goods
from goodPs;

select * from #goods

drop table #goods




declare @maxShipId int;
select @maxShipId = max(id) + 1 from dbo.Ships;
select @maxShipId;

with positions as (select 
	number + @maxShipId as id,
	((number / 60) * 10) + 4700 + [dbo].[randomFunc](9,0) as x,
	((number % 60) * 10) + 4700 + [dbo].[randomFunc](9,0)as y
from numbers where number < 3600)
select * 
into #positions 
from positions;

select * from #positions;

--get Space Stations which are directly on the same tile as a star:
select 
 #positions.*
into #positionsToCorrect
from dbo.StarMap
inner join #positions
on  (StarMap.position.STX =  #positions.x and  StarMap.position.STY =  #positions.y);

select * from #positionsToCorrect

--move Space Stations which are directly on the same tile as a star a bit 
update  #positions set x = #positions.x - 2 , y = #positions.y + 1 
from #positions 
inner join #positionsToCorrect
on #positionsToCorrect.id = #positions.id



drop table #positionsToCorrect
drop table #positions


*/