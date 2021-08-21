 
 MERGE FAC_firewall_blocked AS TARGET 
 using
(  select  f.*   , coalesce( [cc] , 'BG' ) as CC , getDate() as ETL_Insert , null as ETL_Update
from  ( 
select  distinct [id], message , 
RTRIM( SUBSTRING (message ,  CHARINDEX('SRC=', message )+4, (  CHARINDEX('DST', message ) - CHARINDEX('SRC=', message )-4  ) )) as message_ip ,
REPLACE( RTRIM( SUBSTRING (message ,  CHARINDEX('SRC=', message )+4, (  CHARINDEX('DST', message ) - CHARINDEX('SRC=', message )-4  ) )) , '.', '') as ip_number ,
RTRIM( SUBSTRING (message ,  CHARINDEX('MAC=', message )+4, (  CHARINDEX('SRC=', message ) - CHARINDEX('MAC=', message )-4  ) )) as MAC  ,
RTRIM( SUBSTRING (message ,  CHARINDEX('PROTO=', message )+6, 
                            iif(  ( CHARINDEX('SPT=', message ) - CHARINDEX('PROTO=', message )-6  )<0, CHARINDEX('SPT=', message ), ( CHARINDEX('SPT=', message ) - CHARINDEX('PROTO=', message )-6  )  )
                 )
     ) as protocol   , 
RTRIM( SUBSTRING (message ,  CHARINDEX('DPT=', message ) +4 , 
iif( (  CHARINDEX('WINDOW=', message ) - CHARINDEX('DPT=', message )-4  )< 0 ,  CHARINDEX('DPT=', message ) +4 , (  CHARINDEX('WINDOW=', message ) - CHARINDEX('DPT=', message )-4  )))) as DPT  
from
	[dbo].[firewall_blocked] )  f 
left outer join  
	[dbo].[geo_ip_country] i  on  ip_number between [startIP] and [endIP]
 ) AS SOURCE 
 on TARGET.id = SOURCE.id
 WHEN NOT MATCHED then 
 Insert 
 (        [id],         [message],         [message_ip],         [ip_number],         [MAC],        [protocol],       [DPT], [CC], [ETL_Insert], [ETL_Update])
 values
 ( SOURCE.[id]  ,SOURCE.[message]  ,SOURCE.[message_ip]  ,SOURCE.[ip_number]  ,SOURCE.[MAC]  ,SOURCE.[protocol] ,SOURCE.[DPT]  ,SOURCE.[CC]  ,SOURCE.[ETL_Insert]  ,SOURCE.[ETL_Update] ) ;
