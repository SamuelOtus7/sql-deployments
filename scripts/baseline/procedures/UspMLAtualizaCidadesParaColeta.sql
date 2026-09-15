-- ============================================================
-- BASELINE: dbo.UspMLAtualizaCidadesParaColeta
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaCidadesParaColeta]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLAtualizaCidadesParaColeta]  
as  
begin  
  
  -- inserindo apenas latitude e longitude pois os demais campos serão preenchidos por microserviço
 insert into tb_dra_cidades_geo  
	 (
	 dcg_nr_latitude
	,dcg_nr_longitude
	 )
 select   
  distinct   
  cast(LatitudeEnderecoParada as decimal(18,9)) LatitudeEnderecoParada,   
  cast(LongitudeEnderecoParada as decimal(18,9)) LongitudeEnderecoParada
  --null Cidade,  
  --null Cep,  
  --null Estado,   
  --null [dcg_distrito],  
  --null [dcg_ds_cidade_distrito]  
 from   
  tb_ml_pacotes a  
  left join tb_dra_cidades_geo d on cast(a.LatitudeEnderecoParada as decimal(18,9)) = d.dcg_nr_latitude   
  and cast(a.LongitudeEnderecoParada as decimal(18,9)) = d.dcg_nr_longitude   
 where   
  isnumeric(LatitudeEnderecoParada) = 1   
  and isnumeric(LongitudeEnderecoParada) = 1  
  and cast(LatitudeEnderecoParada as decimal(18,9)) between -33.751944 and 5.271944   --Limites de coordenadas do brasil conforme IBGE  
  and cast(LongitudeEnderecoParada as decimal(18,9)) between -73.990556 and -34.792778  --Limites de coordenadas do brasil conforme IBGE  
  and LatitudeEnderecoParada is not null  
  and LongitudeEnderecoParada is not null  
  and d.dcg_cd_cidade_gei is null  
  and a.cidadedistante = 1 
  and a.DataReferencia >= dateadd(day,-2,getdate())
  
end


GO
