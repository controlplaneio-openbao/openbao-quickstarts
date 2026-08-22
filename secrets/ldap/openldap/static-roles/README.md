# LDAP Secrets

OpenBao can be configured to provide LDAP credentials using [static roles](https://openbao.org/docs/api/secret/ldap/#static-roles). When static roles are in use, OpenBao connects to LDAP and rotates the passwords of existing users on a defined schedule.

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
1.  Enable the LDAP secrets engine.
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
        binddn='cn=openbao,ou=Users,dc=example,dc=org' \
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

1.  Create a static role for Alice. In this example, OpenBao will rotate the password of the entry matching the DN every 10 minutes.
    ```bash
    bao write ldap/static-role/alice \
        username='alice' \
        dn='cn=alice,ou=Users,dc=example,dc=org' \
        rotation_period='10m'
    ```
    <details>
    <summary>Sample output</summary>
    <pre>Success! Data written to: ldap/static-role/alice</pre>
    </details>

1.  Exit the openbao container.

# Authenticate to LDAP
1.  Exec into the client container using `make exec-client` and read Alice's current password from OpenBao. The current password, TTL of the current password and last password are returned. The TTL indicates the amount of time remaining before the current password is rotated.
    ```bash
    bao read ldap/static-cred/alice
    ```
    <details>
    <summary>Sample output</summary>
    <pre>
    Key                    Value
    ---                    -----
    dn                     cn=alice,ou=Users,dc=example,dc=org
    last_password          K0^InH9sP5GKe9HQB@Cq
    last_vault_rotation    2026-08-21T23:41:18.362508255Z
    password               !7lMm9z&oC5IwrZK0q8z
    rotation_period        10m
    ttl                    8m28s
    username               alice
    </pre>


1.  Verify that the current password can be used to authenticate to LDAP.
    ```bash
    ldapwhoami -H ldap://openldap:389 \
        -D "cn=alice,ou=Users,dc=example,dc=org" \
        -W
    ```
    <details>
    <summary>Sample output</summary>
    <pre>
    Enter LDAP Password: 
    dn:cn=alice,ou=Users,dc=example,dc=org</pre>
    </details>

# Stop the Example
1.  Exit the client container and stop the example using:
    ```bash
    make down
    ```