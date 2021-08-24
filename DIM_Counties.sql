select     distinct cc , country into DIM_Counties  from    [dbo].[geo_ip_country] s

merge  DIM_Counties Target
using ( 
 select     distinct cc , country      from    [dbo].[geo_ip_country] 
     )
		Source
 on Target.cc=Source.cc 
 WHEN NOT MATCHED then 
 Insert
 (cc , country  )
 ValueS 
 (Source.cc , Source.country) ;
  
  
--  select distinct MAC into DIM_MAC from FAC_firewall_blocked

 select   MAC ,count(MAC)  from FAC_firewall_blocked group by mac

 