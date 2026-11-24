import SpectraCore

/// Process-lifetime copies of core's compile-time tables, fetched once on
/// first use. Do not cache secret inputs or helpers that are already cheap
/// local lookups.
enum CoreReferenceTables {
    static let assetWiki: [AssetWikiEntry] = listAssetWiki()
    static let chainWiki: [ChainWikiEntry] = listChainWiki()
    /// The bounds core holds edits to, for the controls that set them.
    static let bounds: InputBounds = inputBounds()
    /// What staking means on each chain that stakes.
    private static let stakingByChain = Dictionary(uniqueKeysWithValues: listStakingChains().map { ($0.chain, $0) })
    /// The endpoint catalog as settings groups it. Core networking reads its
    /// own catalog.
    private static let endpointSettingsByChain = Dictionary(
        uniqueKeysWithValues: endpointSettings().map { ($0.chainId, $0) })
    /// The project's donation addresses, validated by core when its catalog
    /// loads.
    static let donationDestinations: [DonationDestination] = SpectraCore.donationDestinations()

    static func stakingEntry(for chain: Chain) -> StakingChainEntry? { stakingByChain[chain] }
    /// The catalog's endpoints for `chain`, grouped as settings lists them.
    static func endpointGroups(for chain: Chain) -> [EndpointSettingsGroup] {
        endpointSettingsByChain[chain]?.groups ?? []
    }
}
