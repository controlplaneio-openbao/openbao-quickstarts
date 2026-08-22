# LDAP Secrets

OpenBao can be configured to provide LDAP credentials using [dynamic roles](https://openbao.org/docs/api/secret/ldap/#dynamic-roles). When dynamic roles are in use, OpenBao connects to LDAP and provisions user accounts when requested. The credentials of the dynamically created user accounts are leased and the accounts are automatically deleted when the lease expires.

1. [Start the Example](#start-the-example)
1. [Create a Password Policy](#create-a-password-policy)
1. [Configure the LDAP Secrets Engine](#configure-the-ldap-secrets-engine)
1. [Authenticate to LDAP](#authenticate-to-ldap)
1. [Stop the Example](#stop-the-example)

# Start the Example
1.  The example can be started as shown below.
    ```bash
    make up
    ```

    Once this completes there will be three containers running:
    - **openbao** - The OpenBao server.
    - **openldap** - The OpenLDAP server.
    - **client** -  The container used to configure and test OpenBao.

# Create a Password Policy
1.  Exec into the openbao container using `make exec-openbao` and create a [password policy](https://openbao.org/docs/concepts/password-policies/). The password policy will be used by OpenBao when generating passwords for LDAP users.
    ```bash
    bao write sys/policies/password/ldap-password policy=@/tmp/config/ldap-password.hcl
    ```

# Configure the LDAP Secrets Engine
1.  Exec into the openbao container using `make exec-openbao` and enable the LDAP secrets engine.
    ```bash
    bao secrets enable ldap
    ```
    <details>
    <summary>Sample output</summary>
    <pre>Success! Enabled the ldap secrets engine at: ldap/</pre>
    </details>

1.  Configure the LDAP secrets engine.
    ```bash
    bao write ldap/config \
        url='ldap://openldap:389' \
        binddn='cn=openbao,ou=Services,dc=example,dc=org' \
        bindpass='password123' \
        schema='openldap' \
        userdn='ou=Users,dc=example,dc=org' \
        password_policy=ldap-password
    ```
    <details>
    <summary>Sample output</summary>
    <pre>Success! Data written to: ldap/config</pre>
    </details>

1.  Rotate the root password used by OpenBao to connect to LDAP.
    ```bash
    bao write -f ldap/rotate-root
    ```
    <details>
    <summary>Sample output</summary>
    <pre>Success! Data written to: ldap/rotate-root</pre>
    </details>

1.  Create a dynamic role for a service account. In this example, OpenBao will dynamically create LDAP entries with a lease of 10 minutes.
    ```bash
    bao write ldap/role/svc-acct \
        creation_ldif=@/tmp/config/creation.ldif \
        deletion_ldif=@/tmp/config/deletion.ldif \
        rollback_ldif=@/tmp/config/rollback.ldif \
        default_ttl=10m \
        max_ttl=30m
    ```
    <details>
    <summary>Sample output</summary>
    <pre>Success! Data written to: ldap/role/svc-acct</pre>
    </details>

1.  Exit the openbao container.

# Authenticate to LDAP
1.  Exec into the client container using `make exec-client` and read the service account's credentials from OpenBao. The credentials are returned with a lease which can be renewed. Once the lease expires, the dynamically created entry will be removed from LDAP.
    ```bash
    bao read ldap/creds/svc-acct
    ```
    <details>
    <summary>Sample output</summary>
    <pre>
    Key                    Value
    ---                    -----
    lease_id               ldap/creds/svc-acct/vyWRcDqsM9Y62qbaJkElxFh8
    lease_duration         10m
    lease_renewable        true
    distinguished_names    [cn=v_token_svc-acct_Jqh5AK9gHB_1787369869,ou=Services,dc=example,dc=org]
    password               7NYV1JFbpJV!mTbNJQT@
    username               v_token_svc-acct_Jqh5AK9gHB_1787369869
    </pre>


1.  Verify that the credentials can be used to authenticate to LDAP. Substitute the distinguished name and password returned from the command above.
    ```bash
    ldapwhoami -H ldap://openldap:389 \
        -D "cn=v_token_svc-acct_Jqh5AK9gHB_1787369869,ou=Services,dc=example,dc=org" -W
    ```
    <details>
    <summary>Sample output</summary>
    <pre>
    Enter LDAP Password: 
    dn:cn=v_token_svc-acct_lSzL44EPuE_1787368245,ou=Services,dc=example,dc=org</pre>
    </details>

# Stop the Example
1.  Exit the client container and stop the example using:
    ```bash
    make down
    ```