tailwind.config = {
    theme: {
        extend: {
            typography: {
                DEFAULT: {
                    css: {
                        // Make sure empty paragraphs take up space
                        'p:empty, p:has(:only-child:empty)': {
                            minHeight: '1em',
                            marginBottom: '1em',
                        },
                    },
                }
            }
        }
    }
}

const toggleDropdown = (node_id) => {
    //closeOtherDropdowns(`menu-${node_id}`);

    const el = document.getElementById(`menu-${node_id}`);
    if (el) {
        el.classList.toggle('hidden');
    }
};

const closeOtherDropdowns = (current) => {
    const els = document.getElementsByClassName('menu-dropdown');
    for (let el of els) {
        if (!el.classList.contains('hidden') && current !== el.id) {
            el.classList.add('hidden');
        }
    }
};

const closeModal = () => {
    const el = document.getElementById('modal');
    if (!el.classList.contains('hidden')) {
        el.classList.add('hidden');
    }
};

window.onclick = function (event) {
    const modal = document.getElementById('modal');
    if (event.target === modal) {
        modal.classList.add('hidden');
    }
}

function subscribeToProduct() {
    var productSlug = document.querySelector("[data-product-slug]").getAttribute("data-product-slug");
    var gameServerId = document.getElementById('gameServerDropdown')?.value;
    var customVariableInputs = document.querySelectorAll('select[id^="customVariables"], input[id^="customVariables"]');

    const query = new URLSearchParams({
        subscription: true
    });

    if (gameServerId) {
        query.set('gameserver_id', gameServerId);
    }
    customVariableInputs?.forEach(input => {
        query.set(`custom_variables[${input.name}]`, input.value)
    });

    const checkoutUrl = `/cart/add/${productSlug}?${query.toString()}`;
    window.location.href = checkoutUrl;
}

function addProductToCart() {
    var productSlug = document.querySelector("[data-product-slug]").getAttribute("data-product-slug");
    var gameServerId = document.getElementById('gameServerDropdown')?.value;
    var customVariableInputs = document.querySelectorAll('select[id^="customVariables"], input[id^="customVariables"]');

    const query = new URLSearchParams();
    if (gameServerId) {
        query.set('gameserver_id', gameServerId);
    }
    customVariableInputs?.forEach(input => {
        query.set(`custom_variables[${input.name}]`, input.value)
    });

    const checkoutUrl = `/cart/add/${productSlug}?${query.toString()}`;
    window.location.href = checkoutUrl;
}

const alertEl = document.getElementById("notification-alert");
if (alertEl) {
    setTimeout(() => {
        alertEl.classList.add("opacity-0");
    }, 4000);
}

function toggleGiftActions() {
    var mainActions = document.getElementById('mainActions');
    var giftActions = document.getElementById('giftActions');

    if (mainActions && giftActions) {
        mainActions.classList.toggle('hidden');
        giftActions.classList.toggle('hidden');
    } else {
        console.error('Elements not found');
    }
}

function isValidSteamID(steamid) {
    var numericCheck = /^[0-9]+$/.test(steamid);
    var lengthCheck = steamid.length >= 16 && steamid.length <= 20;

    return numericCheck && lengthCheck;
}

function handlePurchase(platform) {
    var idInput = document.getElementById('idInput');
    var id = idInput.value.trim();
    var productSlug = document.querySelector("[data-product-slug]").getAttribute("data-product-slug");
    var gameServerId = document.getElementById('gameServerDropdown')?.value;
    var customVariableInputs = document.querySelectorAll('select[id^="customVariables"], input[id^="customVariables"]');

    const query = new URLSearchParams({
        "gift_to": id,
        "gift_platform": platform
    });

    if (!isValidSteamID(id) && platform === 'steam') {
        alert("Please enter a valid SteamID64!");
        return;
    }

    if (gameServerId) {
        query.set('gameserver_id', gameServerId);
    }
    customVariableInputs?.forEach(input => {
        query.set(`custom_variables[${input.name}]`, input.value)
    });

    var checkoutUrl = `/products/${productSlug}/checkout?${query.toString()}`;
    window.location.href = checkoutUrl;
}
