<cfsetting enablecfoutputonly="true" />
<!----------------------------------------
ENVIRONMENT
----------------------------------------->
<cfparam name="url.module" type="string" />

<cfoutput>
<a href="##" onclick="$('SelectedObjectID#Request.farcryForm.Name#').value='#stobj.objectid#';$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value='update';forms.#Request.farcryForm.Name#.submit();" title="Update">Update</a>
</cfoutput>

<cfsetting enablecfoutputonly="false" />