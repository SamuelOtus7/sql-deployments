-- ============================================================
-- BASELINE: dbo.UspExpurgoDraColeta
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspExpurgoDraColeta]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspExpurgoDraColeta]
  
as  

declare @data_ini date = cast(dateadd(month,-2,getdate()) as date)  
declare @data_fim date = cast(dateadd(day,-2,getdate()) as date)  
declare @data date = @data_fim

--db_Irisys_Json.dbo.tb_dra_coleta

delete from db_Irisys_Json.dbo.tb_dra_coleta
where dac_dh_referencia <= @data_ini 

while @data >= @data_ini
begin  
	delete dra  
	from db_Irisys_Json.dbo.tb_dra_coleta as dra with(nolock)  
		left join tb_clientes as clientes on dra.dac_cd_transportadora = clientes.cli_id_logistics
		left join (  
			select
				max(dac_cd_coleta) as dac_cd_coleta  
			from db_Irisys_Json.dbo.tb_dra_coleta with(nolock) 
			where dac_dh_referencia >= @data  
			and dac_dh_referencia < dateadd(day,1,@data)
			group by dac_ds_tipo_coleta,  
					dac_ds_contexto,  
					cast(dac_dh_referencia as date)  
		) as Ultimo  
		on dra.dac_cd_coleta = ultimo.dac_cd_coleta
	where dra.dac_dh_referencia >= @data  
		and dra.dac_dh_referencia < dateadd(day,1,@data)
		  and (Ultimo.dac_cd_coleta is null or clientes.cli_in_ativo = 0)
		
	set @data = dateadd(day,-1,@data)  
	print ('Dados expurgados do dia:' + convert(varchar,@data,103))  
end  
  

 --tb_dra_erros

delete from tb_dra_erros_coleta
where dec_dt_referencia <= @data_ini 

while @data >= @data_ini
begin  
	delete dra  
	from tb_dra_erros_coleta as dra with(nolock)  
		left join tb_clientes as clientes on dra.dec_cd_transportadora = clientes.cli_id_logistics
	where dra.dec_dt_referencia >= @data  
	and dra.dec_dt_referencia < dateadd(day,1,@data)
		  or clientes.cli_in_ativo = 0
		
	set @data = dateadd(day,-1,@data)  
	print ('Dados expurgados do dia:' + convert(varchar,@data,103))  
end  
  

  --tb_dra_historico_rotas
delete hist
from tb_dra_historico_rotas as hist
	left join (
			select max(dhr_cd_historico_rota) as Ultimo
			from tb_dra_historico_rotas
			group by dhr_nr_rota, 
						dhr_dt_data
		) as ultimo
	on hist.dhr_cd_historico_rota = ultimo.Ultimo
where ultimo.Ultimo is null
GO
