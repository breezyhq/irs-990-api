_ = require 'lodash'
{cknex, GraphqlFormatter} = require 'backend-shared'

IrsFund = require './model'
IrsFund990 = require '../irs_fund_990/model'
IrsContribution = require '../irs_contribution/model'

module.exports = {
  Query:
    irsFund: (rootValue, {ein}) ->
      IrsFund.getByEin ein

    irsFunds: (rootValue, {query, limit}) ->
      console.log 'search'
      start = Date.now()
      IrsFund.search {query, limit}
      .then (r) ->
        console.log Date.now() - start
        r
      .then GraphqlFormatter.fromElasticsearch

  IrsFund:
    yearlyStats: (irsFund) ->
      irs990s = await IrsFund990.getAllByEin irsFund.ein
      irs990s = _.orderBy irs990s, 'year'
      {
        years: _.map irs990s, (irs990) ->
          {
            year: irs990.year
            assets: irs990.assets?.eoy
          }
      }
}
