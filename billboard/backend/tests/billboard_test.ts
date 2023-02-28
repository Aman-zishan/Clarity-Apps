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
        let rent_wallet_1 = chain.mineBlock([
            Tx.contractCall(
                'billboard',
                'rent-billboard',
                [msg, duration],
                wallet_1.address
            ),
        ])

        rent_wallet_1.receipts[0].result.expectOk()
    },
})

Clarinet.test({
    name: 'rent-billboard should prevent rental if billboard is already occupied',
    async fn(chain: Chain, accounts: Map<string, Account>) {
        let wallet_1 = accounts.get('wallet_1')!
        let wallet_2 = accounts.get('wallet_2')!
        const wallet_3 = accounts.get('wallet_3')!
        const msg_wallet_1 = types.utf8('lorem ipsum of wallet_1')
        const msg_wallet_2 = types.utf8('lorem ipsum of wallet_2')
        const duration_wallet_1 = types.uint(1)
        const duration_wallet_2 = types.uint(2)

        let rental_by_wallet_1 = chain.mineBlock([
            Tx.contractCall(
                'billboard',
                'rent-billboard',
                [msg_wallet_1, duration_wallet_1],
                wallet_1.address
            ),
        ])

        let rental_by_wallet_2 = chain.mineBlock([
            Tx.contractCall(
                'billboard',
                'rent-billboard',
                [msg_wallet_2, duration_wallet_2],
                wallet_2.address
            ),
        ])

        rental_by_wallet_1.receipts[0].result.expectOk()
        rental_by_wallet_2.receipts[0].result.expectErr(types.uint(101))

        const billboard_owner = chain.callReadOnlyFn(
            'billboard',
            'get-billboard-owner',
            [],
            wallet_3.address
        )
        assertEquals(billboard_owner.result, wallet_1.address)
    },
})
