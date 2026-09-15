-- ============================================================
-- BASELINE: dbo.UspDetalhePagamento_validacao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspDetalhePagamento_validacao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspDetalhePagamento_validacao] 
(
    @CodPeriodoPagamento int
    ,@codrota varchar(50) = null
	,@avulso int = null -- codigo espelho
)
as


set nocount on
--
BEGIN TRY

drop table if exists #periodo_pagamento
select lst_ds_valor, ROW_NUMBER() OVER (ORDER BY lst_ds_valor) as rownum
into #periodo_pagamento
from tb_periodos_espelhos_pagamento as a
inner join tb_lista as b
on pep_cd_cliente_transportadora = lst_cd_lista
where pep_cd_periodo_pagamento = @CodPeriodoPagamento
and pep_cd_cliente <> 27

declare @maximo int = (select max(rownum) from #periodo_pagamento)
declare @min int = 1
declare @clientetransportadora varchar(50) 

while @min <= @maximo
begin
  
  set @clientetransportadora = (select lst_ds_valor from #periodo_pagamento where rownum = @min)

  
	set @avulso  = (case when @avulso = 0 then null else @avulso end )

	if @clientetransportadora  = 'mercado_livre'

	begin
		exec UspFinGeraPagamento @CodPeriodoPagamento, @codrota, @avulso;
	END
	else if @clientetransportadora  = 'shopee'
	BEGIN
		exec UspSpeFinGeraPagamento @CodPeriodoPagamento, @codrota, @avulso;
	end
	else if @clientetransportadora  = 'Interno'
	BEGIN
		exec UspFinGeraEspelhoPagamentoInternos @CodPeriodoPagamento;
	end

	exec [UspFinGeraDescontoPagamento] @CodPeriodoPagamento


	--coloque aqui a etapa de aluguel

	--exec UspRecalculaApoioPercentual @CodPeriodoPagamento

	--EXEC UspFinAtualizaLancamentoManual @CodPeriodoPagamento, @codrota;


	exec UspFinAtualizaEspelhoConsolidado @CodPeriodoPagamento
	

set @min = @min + 1

end 
select 1 [value]
END TRY
BEGIN CATCH
	 
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = 0;

select 0 [value]

END CATCH;

 
set nocount off
GO
