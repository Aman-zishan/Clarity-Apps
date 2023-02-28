import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types,
} from 'https://deno.land/x/clarinet@v1.4.2/index.ts'
import {
    assertEquals,
    assert,
} from 'https://deno.land/std@0.170.0/testing/asserts.ts'

Clarinet.test({
    name: 'get-block-height returns the current block-height',
    async fn(chain: Chain, accounts: Map<string, Account>) {
        let wallet_1 = accounts.get('wallet_1')!
        const msg = chain.callReadOnlyFn(
            'billboard',
            'get-block-height',
            [],
            wallet_1.address
        )

        console.log(msg.result)
    },
})

Clarinet.test({
    name: 'get-rent returns the current rent of the billboard set by the admin',
    async fn(chain: Chain, accounts: Map<string, Account>) {
        let results = [...accounts.values()].map(account => {
            const msg = chain.callReadOnlyFn(
                'billboard',
                'get-rent',
                [],
                account.address
            )
            return msg.result
        })

        assert(results.length > 0)
        results.forEach(msg => msg.expectUint(100))
    },
})

Clarinet.test({
    name: 'set-new-rent allows admin to change the rent amount',
    async fn(chain: Chain, accounts: Map<string, Account>) {
        let deployer = accounts.get('deployer')!

        const new_rent = 200
        let block = chain.mineBlock([
            Tx.contractCall(
                'billboard',
                'set-new-rent',
                [types.uint(new_rent)],
                deployer.address
            ),
        ])
        block.receipts[0].result.expectOk()
        let results = [...accounts.values()].map(account => {
            const msg = chain.callReadOnlyFn(
                'billboard',
                'get-rent',
                [],
                account.address
            )
            return msg.result
        })
        assert(results.length > 0)
        results.forEach(msg => msg.expectUint(200))
    },
})

Clarinet.test({
    name: 'set-new-rent should not allow account that are not admin to change the rent amount',
    async fn(chain: Chain, accounts: Map<string, Account>) {
        let wallet_1 = accounts.get('wallet_1')!

        const new_rent = 200
        let block = chain.mineBlock([
            Tx.contractCall(
                'billboard',
                'set-new-rent',
                [types.uint(new_rent)],
                wallet_1.address
            ),
        ])
        block.receipts[0].result.expectErr(types.uint(100))
    },
})

Clarinet.test({
    name: 'rent-billboard should allow account to rent the billboard',
    async fn(chain: Chain, accounts: Map<string, Account>) {
        let wallet_1 = accounts.get('wallet_1')!
        const msg = types.utf8('lorem ipsum')
        const duration = types.uint(1)
        let block = chain.mineBlock([
            Tx.contractCall(
                'billboard',
                'rent-billboard',
                [msg, duration],
                wallet_1.address
            ),
        ])
        const msgq = chain.callReadOnlyFn(
            'billboard',
            'get-billboard',
            [],
            wallet_1.address
        )

        console.log(block.receipts[0].result)
    },
})
