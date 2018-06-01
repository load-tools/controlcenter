import connexion
import logging


def init_app():
    options = {'swagger_path': '/'}
    app = connexion.App(__name__, specification_dir='./', options={})

    flask_app = app.app
    flask_app.config.from_envvar('APPLICATION_SETTINGS')

    logto = flask_app.config['LOGTO']
    file_handler = logging.FileHandler(logto)
    file_handler.setLevel(logging.DEBUG if flask_app.config["DEBUG"] else logging.INFO)
    formatter = logging.Formatter("%(asctime)s\t%(levelname)s\t%(message)s")
    file_handler.setFormatter(formatter)

    logger = flask_app.logger
    logger.addHandler(file_handler)
    logging.info("Started logging to: %s", logto)

    app.add_api('api.yaml')
    return app.app
    # app.run(port=80)


application = init_app()
