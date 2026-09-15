-- ============================================================
-- BASELINE: dbo.usp_financeiro_divergencias_a_pagar
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_financeiro_divergencias_a_pagar]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_financeiro_divergencias_a_pagar]
as
drop table if exists #Tabela_Pagamento_Rota

CREATE TABLE #Tabela_Pagamento_Rota (
    ppr_cd_pagamento_rota INT,
    TenantId INT,
    ppr_cd_periodo INT,
    pgp_nm_periodo VARCHAR(50),
    Data DATE,
    Motorista VARCHAR(100),
    Rota VARCHAR(50),
    SVC VARCHAR(50),
    Faixa_KM VARCHAR(50),
    Tipo_Veiculo VARCHAR(50),
    Cidade VARCHAR(50),
    Ciclo VARCHAR(50),
    CicloPMFatura VARCHAR(50),
    Pacotes INT,
    PacotesEntregues INT,
    Pontos DECIMAL(10,2),
    QuantidadeParadas INT,
    Base DECIMAL(10,2),
    Paradas DECIMAL(10,2),
    Risco DECIMAL(10,2),
    Ajudante BIT,
    Dom_Fer BIT,
    Lancamentos DECIMAL(10,2),
    Bonus DECIMAL(10,2),
    Total DECIMAL(10,2),
    RecebMeli DECIMAL(10,2),
    RecebimentoParadas DECIMAL(10,2),
    RecebimentoRisco DECIMAL(10,2),
    RecebimentoDomingo DECIMAL(10,2),
    DeltaRecebPagto DECIMAL(10,2),
    Base_Zerado BIT,
    Base_Com_Valor BIT,
    Parada_Zerado BIT,
    Parada_Com_Valor BIT,
    TotalRotas INT,
    StatusPagamento VARCHAR(50),
    RecebMeli_Zerado BIT,
    RecebMeli_Com_Valor BIT,
    RecebimentoParadas_Zerado BIT,
    RecebimentoParadas_Com_Valor BIT,
    RecebimentoRisco_Zerado BIT,
    RecebimentoRisco_Com_Valor BIT,
    RecebimentoDomingo_Zerado BIT,
    RecebimentoDomingo_Com_Valor BIT,
    RecebimentoTotal DECIMAL(10,2),
    StatusRecebimento VARCHAR(50),
    RecebimentoPrefatura DECIMAL(10,2),
    AusenteIrisys BIT,
    DataAtualizacao DATETIME,
    SVCPreFatura VARCHAR(50),
    FaixaPreFatura VARCHAR(50),
    TipoVeiculoPreFatura VARCHAR(50), 
	KmTotal decimal(10,2),
	KmTotalExcedente decimal(10,2),
	Desconto decimal(10,2),
	Observacao varchar(2000),
	placa varchar(2000),
	datapbi varchar(2000)
		,ambulanciaprefatura varchar(50)
	,pedagio varchar(50)
	,recargaeletrica varchar(50)
);
------select * from #Tabela_Pagamento_Rota where rota = 187890613

INSERT INTO #Tabela_Pagamento_Rota
select *  from fn_relatorio_financeiro(null,null)



drop table  if exists #tabela

SELECT
--pr.Motorista MotoFechamento, sum(pr.Total) TotalIrisys, sum(imp.Valor_Total) TotalCliente
TenantId,
    ppr_cd_periodo,
    pgp_nm_periodo,
  pr.Rota RotaFechamento, 
  imp.ID_Rota RotaCliente, 
  pr.Data DT_Fechamento, 
  pr.Motorista MotoFechamento, 
  pr.Total TotalFechamento, 
  imp.Valor_Total TotalCliente,
  CASE 
 WHEN pr.Total > imp.Valor_Total THEN pr.Total - imp.Valor_Total ELSE 0
  END AS 'DiferencaFechamento Maior',
  CASE 
 WHEN imp.Valor_Total > pr.Total THEN imp.Valor_Total - pr.Total ELSE 0
  END AS 'DiferencaCliente Maior' ,
  pr.Tipo_Veiculo VeiculoFechamento,
  KmTotalExcedente,
  KM_Excedente,
 -- imp.Veiculo VeiculoCliente,
    CASE 
        WHEN imp.Veiculo = 'Utilitários' THEN 'Utilitarios'
 WHEN imp.Veiculo = 'Utilitários SDD' THEN 'Utilit?os SDD'
        WHEN imp.Veiculo = 'Bulk - VUC equipe única Pool' THEN 'Bulk - VUC equipe única Pool'
 WHEN imp.Veiculo = 'Yellow Pool Large Van – Equipe dupla' THEN 'Yellow Pool Large Van ? Equipe dupla'
 WHEN imp.Veiculo = 'Rental Utilitário com Ajudante' THEN 'Rental Utilit?o com Ajudante'
 WHEN imp.Veiculo = 'Rental Utilitário sem Ajudante' THEN 'Rental Utilit?o sem Ajudante'
 WHEN imp.Veiculo = 'Van Frota Fixa - Equipe única' THEN 'Van Frota Fixa - Equipe única'
 WHEN imp.Veiculo = 'Veículo de Passeio' THEN 'Ve?lo de Passeio'
        ELSE imp.Veiculo
    END AS VeiculoCliente,
  pr.Pontos PontosFechamento, 
  imp.Pontos PontosCliente,
  pr.QuantidadeParadas ParadasFechamento, 
  imp.Paradas ParadasCliente,
  pr.SVC SVCFechamento,
  imp.Service_Center SVCCliente,
  pr.Ciclo CicloFechamento,
  imp.Ciclo CicloCliente, 
  --CASE WHEN pr.Ciclo <> imp.Ciclo THEN 'DIFERENTE' ELSE 'IGUAL' END AS 'ComparaCiclo',
  case
	when   pr.Total = imp.Valor_Total  then 'Valor Igual'
	when imp.Valor_Total = 0 then 'Zerado no arquivo do cliente'
  when pr.Ciclo <> imp.Ciclo then 'Ciclo DIferente' -- Clicos Diferentes
  when pr.Tipo_Veiculo <> CASE 
								WHEN imp.Veiculo = 'Utilitários' THEN 'Utilitarios'
								WHEN imp.Veiculo = 'Utilitários SDD' THEN 'Utilit?os SDD'
								WHEN imp.Veiculo = 'Bulk - VUC equipe única Pool' THEN 'Bulk - VUC equipe única Pool'
								WHEN imp.Veiculo = 'Yellow Pool Large Van – Equipe dupla' THEN 'Yellow Pool Large Van ? Equipe dupla'
								WHEN imp.Veiculo = 'Rental Utilitário com Ajudante' THEN 'Rental Utilit?o com Ajudante'
								WHEN imp.Veiculo = 'Rental Utilitário sem Ajudante' THEN 'Rental Utilit?o sem Ajudante'
								WHEN imp.Veiculo = 'Van Frota Fixa - Equipe única' THEN 'Van Frota Fixa - Equipe única'
								WHEN imp.Veiculo = 'Veículo de Passeio' THEN 'Ve?lo de Passeio'
								ELSE imp.Veiculo
							END 
	then 'Km Excedente diferente'
	
	when KmTotalExcedente <> KM_Excedente then 'Km Excedente diferente'

  else 'Nao Mapeados' end Status
  
  into #tabela

FROM 
  #Tabela_Pagamento_Rota pr
  INNER JOIN tb_layout_pagto_importacao imp ON imp.ID_Rota = pr.Rota
 --WHERE 
 --pr.Total <> imp.Valor_Total  
 --  and pr.Motorista <> imp.Motorista -- Motoristas Diferentes
 -- and pr.Ciclo <> imp.Ciclo -- Clicos Diferentes
 -- and pr.Pontos <> imp.Pontos -- Pontos diferentes

--group by pr.Motorista 


--select 
--	Status
--	,count(*) qtd 
--from #tabela
--group by rollup(Status)
--order by 2


select * 
from #tabela  
--where Status in ('Zerado no arquivo do cliente','Ciclo DIferente')



--select *
----VeiculoFechamento,SVCFechamento,count(*)
--from #tabela  where Status = 'Nao Mapeados'
--and VeiculoFechamento in 
--(
--'Bulk - VUC equipe única Pool'
--,'Rental Utilit?o com Ajudante'
--,'Van Frota Fixa - Equipe dupla'
--,'Van Frota Fixa - Equipe única'
--,'Yellow Pool Large Van ? Equipe dupla'
--,'Rental Utilit?o sem Ajudante'
--)

--group by VeiculoFechamento,SVCFechamento
--order by 3,2

--select *
--from #tabela  
--where Status = 'Km Excedente diferente'
----and rotacliente = 187890613
--order by 3,2


--select 
--kmcoletado
--,kmcoletado-100
--,* from vw_rotas
--where idrota in (
--187890613
--)


  --select top 10 * from #Tabela_Pagamento_Rota
  -- select distinct Veiculo from #TempImport
  --select top 10 * from #TempImport;

-- drop table  #Tabela_Pagamento_Rota
--  DROP TABLE #TempImport;

--select * from #Tabela_Pagamento_Rota where rota = 187890613

--select top 10 * from tb_layout_pagto_importacao
GO
