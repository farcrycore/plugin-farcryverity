<cfsetting enablecfoutputonly="true" />
<!----------------------------------------
ENVIRONMENT
----------------------------------------->
<cfparam name="url.module" type="string" />

<cfoutput>
<a href="##" onclick="$('SelectedObjectID#Request.farcryForm.Name#').value='#stobj.objectid#';$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value='create';forms.#Request.farcryForm.Name#.submit();" title="Create">C</a>
<a href="##" onclick="$('SelectedObjectID#Request.farcryForm.Name#').value='#stobj.objectid#';$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value='delete';forms.#Request.farcryForm.Name#.submit();" title="Delete">D</a>
<a href="##" onclick="$('SelectedObjectID#Request.farcryForm.Name#').value='#stobj.objectid#';$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value='purge';forms.#Request.farcryForm.Name#.submit();" title="Purge">P</a>
</cfoutput>

<cfsetting enablecfoutputonly="false" />