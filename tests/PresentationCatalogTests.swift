import Foundation
import SpectraCore
import SwiftUI
import Testing
@testable import Spectra

struct PresentationCatalogTests {
    /// With test networks hidden, a search shows only the networks it finds
    /// that are not test networks, unless it finds nothing else: a test
    /// network asked for by name is the answer, not "No Results".
    @Test func aSearchShowsATestNetworkOnlyWhenItFindsNothingElse() {
        let rows = ChainSelectionDescriptor.popularOrder(Chain.all)
        let peercoin = rows.picked(filter: .all, query: "Peercoin", order: .name, showsTestNetworks: false)
        #expect(peercoin.contains { $0.id == .peercoin })
        #expect(!peercoin.contains { $0.id == .peercoinTestnet })
        let sepolia = rows.picked(filter: .all, query: "Ethereum Sepolia", order: .popular, showsTestNetworks: false)
        #expect(sepolia.map(\.id) == [.ethereumSepolia])
    }

    /// Colour follows deployment identity, never the ticker: a custom token
    /// that calls itself `ETH` is grey, not Ether's colour.
    @Test func coinColorsFollowDeploymentIdentity() throws {
        for token in listAllBuiltinTokenDeployments() {
            if let color = token.color {
                #expect(AssetPresentationCatalog.color(deploymentId: token.deploymentId) == color.color)
            }
        }
        let ethereum = try #require(Chain.ethereum.entry)
        #expect(AssetPresentationCatalog.color(deploymentId: ethereum.nativeDeploymentId) == ethereum.color.color)
        #expect(AssetPresentationCatalog.color(deploymentId: "ethereum:erc-20:0xnot-in-the-catalog") == .gray)
    }

    /// Artwork follows deployment identity too: a custom contract cannot
    /// borrow USDC's mark by copying its symbol, and draws its letter.
    @Test func anUnknownCoinFallsBackToItsLetter() {
        let unknown = AssetHolding.fixture(name: "USD Coin", symbol: "USDC", coingeckoId: "usd-coin", chainId: Chain.ethereum,
            tokenStandard: .erc20, contractAddress: "0xdead", amount: "0")
        #expect(unknown.artworkName == "")
    }

    /// A native asset's display name is its chain's, so naming the pair
    /// unconditionally read "Solana on Solana". The subtitle spells the chain
    /// only when it is not already the asset, and the expectations are built
    /// from the shipped formats so the assertion is about that shape rather
    /// than about English.
    @Test func transactionSubtitleNamesTheChainOnlyWhenItIsNotTheAsset() {
        func subtitle(asset: String, chainId: Chain) -> String {
            TransactionRecord(
                id: "tx", kind: .receive, status: .confirmed, walletName: "Main Wallet",
                assetDisplayName: asset, symbol: "SOL", chainId: chainId, amount: "0.1", address: "address"
            ).subtitleText
        }
        func wallet(_ asset: String) -> String { AppLocalization.format("common.transactionSubtitleFormat", asset, "Main Wallet") }
        func onChain(_ asset: String, _ chain: String) -> String { AppLocalization.format("common.assetOnChainFormat", asset, chain) }

        #expect(subtitle(asset: "Solana", chainId: Chain.solana) == wallet("Solana"))
        #expect(subtitle(asset: "solana", chainId: Chain.solana) == wallet("solana"))
        #expect(subtitle(asset: "USD Coin", chainId: Chain.solana) == wallet(onChain("USD Coin", "Solana")))
        #expect(subtitle(asset: "Bitcoin", chainId: Chain.bitcoinTestnet4) == wallet(onChain("Bitcoin", Chain.bitcoinTestnet4.displayName)))
    }
}
