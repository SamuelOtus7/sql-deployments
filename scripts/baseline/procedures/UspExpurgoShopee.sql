-- ============================================================
-- BASELINE: dbo.UspExpurgoShopee
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspExpurgoShopee]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspExpurgoShopee]
as
begin

	
	declare @data_ini date = cast(dateadd(month,-3,getdate()) as date)  
	declare @data_fim date = cast(dateadd(day,-7,getdate()) as date)  
	declare @data date = @data_fim

	delete 
		webhook
	from 
		db_Irisys_Json.dbo.tb_spe_webhook as webhook
		join tb_clientes as clientes on webhook.idtransportadora = clientes.cli_id_shopee 
	where 
		clientes.cli_in_ativo = 0


	delete 
		webhook
	from 
		db_Irisys_Json.dbo.tb_spe_webhook as webhook
	where 
		webhook.createdAt <= @data_ini
		and agency is null


	while @data >= @data_ini
	begin  
		delete 
			webhook  
		from 
			db_Irisys_Json.dbo.tb_spe_webhook as webhook witH(nolock)
			left join (  
				select
					max(id) as id  
				from 
					db_Irisys_Json.dbo.tb_spe_webhook with(nolock) 
				where 
					createdAt >= @data  
					and createdAt < dateadd(day,1,@data)
				group by 
					TipoJson,  
					CodigoRota,  
					CodigoPacote,
					IdTransportadora,
					Agency
			) as Ultimo  
			on webhook.id = ultimo.id
		where 
			webhook.createdAt >= @data  
			and webhook.createdAt < dateadd(day,1,@data)
			and Ultimo.id is null
		
		set @data = dateadd(day,-1,@data)  
		print ('Dados expurgados do dia:' + convert(varchar,@data,103))  
	end  

end
GO
