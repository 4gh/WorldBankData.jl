using Test
using WorldBankData

indicator_data = Any[
    Dict("total" => 5, "per_page" => "25000", "pages" => 1, "page" => 1),
    Any[
        Dict(
            "sourceOrganization" => "World Bank and International Energy Agency (IEA Statistics © OECD/IEA, http://www.iea.org/stats/index.asp).  ",
            "id" => "12.1_TD.LOSSES",
            "topics" => [],
            "sourceNote" => "Transmission and distribution losses (%): Transmission and distribution (T&D) losses measure power lost in the transmission of (high-voltage) electricity from power generators to distributors and in the distribution of (medium- and low-voltage) electricity from distributors to end-users. T&D losses are represented as a percentage of gross electricity production. They include both technical and nontechnical (or commercial) losses. Included in the latter are unmetered, unbilled, and unpaid electricity, including theft, which could be significant in developing countries. Aggregate T&D system indicators may be dominated by factors other than losses. The location of primary energy resources (such as hydro lakes and coal seams) and large loads (cities and industries) may be more significant factors in T&D efficiency indicators than the losses or efficiency of the transmission system itself. Properly separating true losses (and hence the efficiency potential of transmission systems) from exogenous location and scale factors and nontechnical losses would require detailed studies of system-dynamic interactions and real operating requirements that are not practical for global tracking purposes.",
            "name" => "Transmission and distribution losses (%)",
            "source" => Dict("id" => "35", "value" => "Sustainable Energy for All"),
        ),
        Dict(
            "sourceOrganization" => "World Bank and International Energy Agency (IEA Statistics © OECD/IEA, http://www.iea.org/stats/index.asp).  ",
            "id" => "13.1_INDUSTRY.ENERGY.INTENSITY",
            "topics" => [],
            "sourceNote" => "Energy intensity of industrial sector (MJ/\$2005):  A ratio between energy consumption in industry (including energy industry own use) and industry sector value added measured at purchasing power parity. Energy intensity is an indication of how much energy is used to produce one unit of economic output. Lower ratio indicates that less energy is used to produce one unit of output. ",
            "name" => "Energy intensity of industrial sector (MJ/\$2005)",
            "source" => Dict("id" => "35", "value" => "Sustainable Energy for All"),
        ),
        Dict(
            "sourceOrganization" => "World Bank and International Energy Agency (IEA Statistics © OECD/IEA, http://www.iea.org/stats/index.asp).  ",
            "id" => "14.1_AGR.ENERGY.INTENSITY",
            "topics" => [],
            "sourceNote" => "Energy intensity of agricultural sector (MJ/\$2005):  A ratio between energy consumption in agricultural sector (including forestry and fishing) and agricultural sector value added measured at purchasing power parity. Energy intensity is an indication of how much energy is used to produce one unit of economic output. Lower ratio indicates that less energy is used to produce one unit of output. ",
            "name" => "Energy intensity of agricultural sector (MJ/\$2005)",
            "source" => Dict("id" => "35", "value" => "Sustainable Energy for All"),
        ),
        Dict(
            "sourceOrganization" => "World Bank and International Energy Agency (IEA Statistics © OECD/IEA, http://www.iea.org/stats/index.asp).  ",
            "id" => "15.1_OTHER.SECT.ENER.INTENS",
            "topics" => [],
            "sourceNote" => "Energy intensity of other sectors (MJ/\$2005): A ratio between energy consumption in other sectors (including services, residential and transport) and services sector value added measured at purchasing power parity. Energy intensity is an indication of how much energy is used to produce one unit of economic output. Lower ratio indicates that less energy is used to produce one unit of output. ",
            "name" => "Energy intensity of other sectors (MJ/\$2005)",
            "source" => Dict("id" => "35", "value" => "Sustainable Energy for All"),
        ),
        Dict(
            "sourceOrganization" => "World Bank and International Energy Agency (IEA Statistics © OECD/IEA, http://www.iea.org/stats/index.asp).  ",
            "id" => "16.1_DECOMP.EFFICIENCY.IND",
            "topics" => [],
            "sourceNote" => "The Index is created from the series of year to year Energy Intensity component of the Decomposition Analysis with the DIVISIA LMDI I method. The Significant Period is defined as the period for which the available data is consistent in the energy and value added databases such that all the sectors have energy and value added for those years. The CAGR is calculated over that Significant Period.",
            "name" => "Divisia Decomposition Analysis - Energy Intensity component Index",
            "source" => Dict("id" => "35", "value" => "Sustainable Energy for All"),
        ),
    ],
]

df_indicator = WorldBankData.parse_indicator(indicator_data)

@test df_indicator[!, :indicator] == String[
    "12.1_TD.LOSSES",
    "13.1_INDUSTRY.ENERGY.INTENSITY",
    "14.1_AGR.ENERGY.INTENSITY",
    "15.1_OTHER.SECT.ENER.INTENS",
    "16.1_DECOMP.EFFICIENCY.IND",
]
@test df_indicator[!, :name] == String[
    "Transmission and distribution losses (%)",
    "Energy intensity of industrial sector (MJ/\$2005)",
    "Energy intensity of agricultural sector (MJ/\$2005)",
    "Energy intensity of other sectors (MJ/\$2005)",
    "Divisia Decomposition Analysis - Energy Intensity component Index",
]
