# -*- coding: utf-8 -*-
class Auth::RegistrationsController < Devise::RegistrationsController
        # before_filter :configure_sign_up_params, only: [:create]
        # before_filter :configure_account_update_params, only: [:update]
        before_filter :check_captcha, only: [:create]

        # GET /resource/sign_up
        def new
                @introducer_token = params[:introducer_token]
                super
        end

        # POST /resource
        def create
                @introducer_token = params[:introducer_token]
                super
                if !resource.new_record? && @introducer_token.present?
                        user = User.find_by_introducer_token(@introducer_token)
                        resource.update(introducer: user.id)
                end
        end

        # GET /resource/edit
        # def edit
        #   super
        # end

        # PUT /resource
        # def update
        #   super
        # end

        # DELETE /resource
        # def destroy
        #   super
        # end

        # GET /resource/cancel
        # Forces the session data which is usually expired after sign
        # in to be expired now. This is useful if the user wants to
        # cancel oauth signing in/up in the middle of the process,
        # removing all OAuth session data.
        # def cancel
        #   super
        # end

        # protected

        # You can put the params you want to permit in the empty array.
        # def configure_sign_up_params
        #   devise_parameter_sanitizer.for(:sign_up) << :attribute
        # end

        # You can put the params you want to permit in the empty array.
        # def configure_account_update_params
        #   devise_parameter_sanitizer.for(:account_update) << :attribute
        # end

        # The path used after sign up.
        # def after_sign_up_path_for(resource)
        #   super(resource)
        # end

        # The path used after sign up for inactive accounts.
        # def after_inactive_sign_up_path_for(resource)
        #   super(resource)
        # end

        private
        def check_captcha
                tel = params[:user][:tel]
                captcha = params[:tel_captcha]
                c = Captcha.find_by_tel(tel)
                if !c.nil? && c.register_token.eql?(captcha)
                        # CAPTCHA correct
                else
                        build_resource(sign_up_params)
                        flash[:error] = "验证码不正确."
                        render "new"
                end
        end

end
