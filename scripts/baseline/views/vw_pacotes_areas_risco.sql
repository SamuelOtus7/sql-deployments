-- ============================================================
-- BASELINE: dbo.vw_pacotes_areas_risco
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_areas_risco]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_pacotes_areas_risco] as 

SELECT distinct 
    pacotes.IdRota
	,pacotes.IdEntrega
	, CEP CepPacote
	,CEP_INICIO
	,CEP_FIM
	,STATUS
	,CAST(areas.CUSTO AS DECIMAL) AS CUSTO,
	cep_inicio_Tratado,
	cep_fim_Tratado

   
    --areas.STATUS,
    --clientes.cli_cd_codigo_cliente AS IdTransportadora,
    --pacotes.DataReferencia

FROM 
    vw_pacotes AS pacotes

inner JOIN 
    tb_areas_de_risco AS areas ON 
    pacotes.cep BETWEEN  CEP_INICIO_tratado and CEP_FIM_TRATADO

INNER JOIN 
   tb_clientes AS clientes 
   ON pacotes.idTransportadora = clientes.cli_id_logistics

inner join vw_rotas as r
on r.IdRota = pacotes.IdRota
and r.ServiceCenter = areas.svc


WHERE 1=1
--and CUSTO is not null
and pacotes.datareferencia >= '2024-10-01'
and pacotes.IdTransportadora = 1491631999
and pacotes.LatitudeEnderecoParada IS NOT NULL
AND pacotes.LongitudeEnderecoParada IS NOT NULL
and r.Ambulancia = 0
--AND IDTRANSPORTADORA=1491631999
-- AND datareferencia = '2024-10-10' --FILTRO TEMPORÁRIO PARA VALIDAÇÕES.
--order by 2
GO
