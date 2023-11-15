//
//  Modular+Templates.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim dohyun on 2023/11/14.
//

import ProjectDescription


public struct ModularFactory {
    var name: ModuleLayer.RawValue
    var platform: Platform
    var products: ProductsType
    var dependencies: [TargetDependency]
    var bundleId: String
    var deploymentTarget: DeploymentTarget?
    var infoPlist: InfoPlist?
    var sources: SourceFilesList?
    var resources: ResourceFileElements?
    var settings: Settings?
    
    
    public init(
        name: ModuleLayer.RawValue = "",
        platform: Platform = .iOS,
        products: ProductsType = .framework(.static),
        dependencies: [TargetDependency] = [],
        bundleId: String = "",
        deploymentTarget: DeploymentTarget? = .defualt,
        infoPlist: InfoPlist? = .default,
        sources: SourceFilesList? = .default,
        resources: ResourceFileElements? = .default,
        settings: Settings? = nil
    ) {
        self.name = name
        self.platform = platform
        self.products = products
        self.dependencies = dependencies
        self.bundleId = bundleId
        self.deploymentTarget = deploymentTarget
        self.infoPlist = infoPlist
        self.sources = sources
        self.resources = resources
        self.settings = settings
    }
}


public struct AppFactory {
    var name: String
    var platform: Platform
    var products: [ProductsType]
    var dependencies: [TargetDependency]
    var bundleId: String
    var deploymentTarget: DeploymentTarget?
    var infoPlist: InfoPlist?
    var sources: SourceFilesList?
    var resources: ResourceFileElements?
    var settings: Settings?
    var entitlements: Path?
    var scripts: [TargetScript]
    
    
    public init(
        name: String = "App",
        platform: Platform = .iOS,
        products: [ProductsType] = [.app, .uiTests, .unitTests],
        dependencies: [TargetDependency] = [],
        bundleId: String,
        deploymentTarget: DeploymentTarget? = .defualt,
        infoPlist: InfoPlist? = .default,
        sources: SourceFilesList? = .default,
        resources: ResourceFileElements? = .default,
        settings: Settings? = nil,
        entitlements: Path? = nil,
        scripts: [TargetScript] = []
    ) {
        self.name = name
        self.platform = platform
        self.products = products
        self.dependencies = dependencies
        self.bundleId = bundleId
        self.deploymentTarget = deploymentTarget
        self.infoPlist = infoPlist
        self.sources = sources
        self.resources = resources
        self.settings = settings
        self.entitlements = entitlements
        self.scripts = scripts
    }
    
    
}


public extension Project {
    static func makeApp(name: String, target: [Target]) -> Project {
        //TODO: Scheme 추가 예정
        return Project(
            name: name,
            targets: target
        )
    }
    
    
}


public extension Target {
    static func makeModular(layer: ModuleLayer, factory: ModularFactory) -> Target {
        
        switch layer {
        case .App:
            return Target(
                name: layer.rawValue,
                platform: factory.platform,
                product: factory.products.isApp ? .app : .staticLibrary,
                bundleId: "com.\(layer.rawValue).project".lowercased(),
                deploymentTarget: factory.deploymentTarget,
                infoPlist: factory.infoPlist,
                sources: factory.sources,
                resources: factory.resources,
                dependencies: factory.dependencies,
                settings: factory.settings
            )
        case .Data:
            return Target(
                name: layer.rawValue,
                platform: factory.platform,
                product: factory.products.isLibrary ? .staticLibrary : .dynamicLibrary,
                bundleId: "com.\(layer.rawValue).project".lowercased(),
                deploymentTarget: factory.deploymentTarget,
                infoPlist: factory.infoPlist,
                sources: factory.sources,
                resources: factory.resources,
                dependencies: factory.dependencies,
                settings: factory.settings
            )
        case .Domain:
            return Target(
                name: layer.rawValue,
                platform: factory.platform,
                product: factory.products.isFramework ? .staticFramework : .framework,
                bundleId: "com.\(layer.rawValue).project".lowercased(),
                deploymentTarget: factory.deploymentTarget,
                infoPlist: factory.infoPlist,
                sources: factory.sources,
                resources: factory.resources,
                dependencies: factory.dependencies,
                settings: factory.settings
            )
        case .Core:
            return Target(
                name: layer.rawValue,
                platform: factory.platform,
                product: factory.products.isLibrary ? .staticLibrary : .dynamicLibrary,
                bundleId: "com.\(layer.rawValue).project".lowercased(),
                deploymentTarget: factory.deploymentTarget,
                infoPlist: factory.infoPlist,
                sources: factory.sources,
                resources: factory.resources,
                dependencies: factory.dependencies,
                settings: factory.settings
            )
        case .DesignSystem:
            return Target(
                name: layer.rawValue,
                platform: factory.platform,
                product: factory.products.isFramework ? .staticFramework : .framework,
                bundleId: "com.\(layer.rawValue).project".lowercased(),
                deploymentTarget: factory.deploymentTarget,
                infoPlist: factory.infoPlist,
                sources: factory.sources,
                resources: factory.resources,
                dependencies: factory.dependencies,
                settings: factory.settings
            )
        }
        
    }
    
}
