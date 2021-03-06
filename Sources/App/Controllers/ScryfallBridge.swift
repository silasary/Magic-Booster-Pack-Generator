//
//  ScryfallBridge.swift
//  TabletopSimulatorMagicBoosterPackServer
//
//  Created by Josh Birnholz on 11/6/20.
//

import Vapor
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Swiftfall.ScryfallSet: Content {
	
}

final class ScryfallBridgeController {
	
	static let customSets = [
	Swiftfall.ScryfallSet(code: "net", mtgo: nil, name: "Netropolis (Custom Set)", uri: "", scryfallUri: "", searchUri: "", releasedAt: nil, setType: "expansion", cardCount: 0, digital: true, foilOnly: false, blockCode: "net", block: "net", iconSvgUri: nil)
	]
	
	func getSets(_ req: Request) throws -> EventLoopFuture<[Swiftfall.ScryfallSet]> {
		let promise: Promise<[Swiftfall.ScryfallSet]> = req.eventLoop.newPromise()
		
		DispatchQueue.global(qos: .userInitiated).async {
			do {
				let allowedSetTypes: Set<String> = [
					"core",
					"expansion",
					"masters",
					"draft_innovation"
				]
				
				let disallowedSetCodes: Set<String> = [
					"plist"
				]
				
				var sets: [Swiftfall.ScryfallSet] = try Swiftfall.getSetList().data.compactMap {
					guard allowedSetTypes.contains($0.setType),
						  let code = $0.code,
						  !disallowedSetCodes.contains(code)
					else { return nil }
					
					var set = $0
					
					if set.code == "mb1" {
						set.code = "cmb1"
						set.name = "Mystery Booster (Convention Edition)"
					}
					
					if set.code == "fmb1" {
						set.name = "Mystery Booster (Retail Edition)"
					}
					
					if set.code == "tsr", set.cardCount < 390 {
						return nil
					}
					
					return set
				}
				
				sets.append(contentsOf: Self.customSets)
				
				promise.succeed(result: sets)
			} catch {
				promise.fail(error: error)
			}
		}
		
		return promise.futureResult
	}
	
}
