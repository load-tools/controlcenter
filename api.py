import logging
import yaml
from StringIO import StringIO

from werkzeug.exceptions import BadRequest

from yandextank.config_converter.converter import ConversionError
from yandextank.core.consoleworker import load_core_base_cfg, load_local_base_cfgs, convert_ini
from yandextank.validator.validator import TankConfig


def response(full_cfg, errors):
    return {'config': full_cfg, 'errors': errors}


def get_validation_result(cfg):
    config, errors, configinitial = TankConfig([load_core_base_cfg()] +
                                               load_local_base_cfgs() +
                                               [cfg],
                                               with_dynamic_options=False).validate()
    return response(configinitial, errors)


def validate_config(config, fmt):

    if fmt == 'ini':
        stream = StringIO(str(config.read()))
        config.close()
        try:
            return get_validation_result(convert_ini(stream))
        except ConversionError as e:
            return response({}, [e.message])
        except Exception as e:
            logging.error('Exception during reading Tank config', exc_info=True)
            raise BadRequest('{}'.format(e))
    else:
        try:
            return get_validation_result(yaml.load(config))
        except Exception as e:
            logging.error('Exception during reading Tank config', exc_info=True)
            raise BadRequest('{}'.format(e))


def validate_config_json(config):
    try:
        return get_validation_result(config)
    except Exception as e:
        logging.error('Exception during reading Tank config', exc_info=True)
        raise BadRequest('{}'.format(e))
