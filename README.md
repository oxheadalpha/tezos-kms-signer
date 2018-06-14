# remote_signer

This is a Python Flask app that receives block headers
and passes them on to the baker CloudHSM to be signed.

## installation

```
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
```

## execution
```
export HSM_PRIV_KEY_HANDLE=7
export HSM_PUB_KEY_HANDLE=9
export HSM_USER=resigner
export HSM_PASSWORD=blah
export HSM_LIBFILE=/opt/cloudhsm/lib/libcloudhsm_pkcs11.so
export HSM_SLOT=1
export RPC_ADDR=localhost
export RPC_PORT=8732
FLASK_APP=signer flask run
```

## running the tests
```
export HSM_PRIV_KEY_HANDLE=7
export HSM_PUB_KEY_HANDLE=9
export HSM_USER=resigner
export HSM_PASSWORD=blah
export HSM_LIBFILE=/opt/cloudhsm/lib/libcloudhsm_pkcs11.so
export HSM_SLOT=1
export RPC_ADDR=localhost
export RPC_PORT=8732
python -m unittest test/test_remote_signer.py
```